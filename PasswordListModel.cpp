#include "PasswordListModel.h"
#include "Encrypter.h"

PasswordListModel::PasswordListModel(QObject *poParent) : QAbstractListModel(poParent)
{
    qDebug() << __FUNCTION__;
    this->fnInit();
}

PasswordListModel::~PasswordListModel()
{
    qDebug() << __FUNCTION__;

    delete this->poJsonObject;
}

void PasswordListModel::fnInit()
{
    qDebug() << __FUNCTION__;

    if (this->poJsonObject) {
        delete this->poJsonObject;
    }

    this->poJsonObject = new QJsonObject();
    (*this->poJsonObject)["passwords"] = QJsonArray();
    (*this->poJsonObject)["history"] = QJsonArray();

    if (this->poPasswordChangeHistoryListModel) {
        delete this->poPasswordChangeHistoryListModel;
    }

    this->poPasswordChangeHistoryListModel = new PasswordChangeHistoryListModel();
    this->poPasswordChangeHistoryListModel->poPasswordListModel = this;
}

void PasswordListModel::fnClearPasswordsArray()
{
    (*this->poJsonObject)["passwords"] = QJsonArray();
}

QJsonArray PasswordListModel::fnGetPasswordsArray() const
{
    return (*this->poJsonObject)["passwords"].toArray();
}

void PasswordListModel::fnSetPasswordsArray(QJsonArray oJsonArray)
{
    (*this->poJsonObject)["passwords"] = oJsonArray;
}

QHash<int,QByteArray> PasswordListModel::roleNames() const
{
    qDebug() << __FUNCTION__;
    return {
        { NameRole, "name" },
        { UserRole, "user" },
        { PasswordRole, "password" },
        { IsDeletedRole, "isDeleted" },
        { AdditionalRole, "additional" },
        { IDRole, "id" },
        { SourceIndexRole, "sourceIndex" },
        { CreatedAtRole, "createdAt" },
        { UpdatedAtRole, "updatedAt" }
    };
}

QVariant PasswordListModel::data(const QModelIndex &oIndex, int iRole) const
{
    qDebug() << __FUNCTION__;

    QJsonArray oPasswordsJsonArray = this->fnGetPasswordsArray();

    if (!oIndex.isValid())
        return QVariant();

    if (oIndex.row() >= oPasswordsJsonArray.size())
        return QVariant();

    QJsonObject oJsonObject = oPasswordsJsonArray.at(oIndex.row()).toObject();

    if (iRole == NameRole) {
        return oJsonObject["name"].toString();
    } if (iRole == UserRole) {
        return oJsonObject["user"].toString();
    } if (iRole == PasswordRole) {
        return oJsonObject["password"].toString();
    } if (iRole == IsDeletedRole) {
        return oJsonObject["isDeleted"].toBool();
    } if (iRole == AdditionalRole) {
        return oJsonObject["additional"].toString();
    } if (iRole == IDRole) {
        return oJsonObject["id"].toString();
    } if (iRole == SourceIndexRole) {
        return oIndex.row();
    } if (iRole == CreatedAtRole) {
        return oJsonObject["createdAt"].toString();
    } if (iRole == UpdatedAtRole) {
        return oJsonObject["updatedAt"].toString();
    } else
        return QVariant();
}

bool PasswordListModel::setData(const QModelIndex &oIndex, const QVariant &oValue, int iRole)
{
    qDebug() << __FUNCTION__;

    QJsonArray oPasswordsJsonArray = this->fnGetPasswordsArray();

    if (oIndex.isValid() /*&& iRole == Qt::EditRole*/) {
        if (oIndex.row()<oPasswordsJsonArray.size()) {
            QJsonObject oJsonObject = oPasswordsJsonArray.at(oIndex.row()).toObject();

            this->poPasswordChangeHistoryListModel->fnAddJsonObject("update", oJsonObject);

            if (iRole == NameRole) {
                oJsonObject["name"] = oValue.toString();
            }
            if (iRole == UserRole) {
                oJsonObject["user"] = oValue.toString();
            }
            if (iRole == PasswordRole) {
                oJsonObject["password"] = oValue.toString();
            }
            if (iRole == AdditionalRole) {
                oJsonObject["additional"] = oValue.toString();
            }
            if (iRole == IDRole) {
                oJsonObject["id"] = oValue.toString();
            }
            oJsonObject["updatedAt"] = QDateTime::currentDateTime().toString("dd.MM.yyyy hh:mm:ss");

            QJsonValue oJsonValue(oJsonObject);
            oPasswordsJsonArray.replace(oIndex.row(), oJsonValue);

            this->fnSetPasswordsArray(oPasswordsJsonArray);
        }

        emit dataChanged(oIndex, oIndex, { iRole });

        this->fnSave();

        return true;
    }
    return false;
}

QVariant PasswordListModel::headerData(
    int iSection,
    Qt::Orientation oOrientation,
    int iRole
) const
{
    qDebug() << __FUNCTION__;

    if (iRole != Qt::DisplayRole)
         return QVariant();

     if (oOrientation == Qt::Horizontal)
         return QString("Column %1").arg(iSection);
     else
         return QString("Row %1").arg(iSection);
}


Qt::ItemFlags PasswordListModel::flags(const QModelIndex &oIndex) const
{
    qDebug() << __FUNCTION__;

    if (!oIndex.isValid())
        return Qt::ItemIsEnabled;

    return QAbstractItemModel::flags(oIndex) | Qt::ItemIsEditable;
}

QString PasswordListModel::fnGenerateIndex(int iLength)
{
    static QVector<QString> oLettersVector;
    QString sResult = "";

    if (oLettersVector.length() == 0) {
        for (int iIndex=97;iIndex<123;iIndex++) {
            oLettersVector.append(QChar(iIndex));
        }
        for (int iIndex=48;iIndex<58;iIndex++) {
            oLettersVector.append(QChar(iIndex));
        }
    }

    qsrand((unsigned int) time(NULL));

    for (int iIndex=0; iIndex<iLength; iIndex++) {
        sResult.append(oLettersVector[qrand() % oLettersVector.length()]);
    }

    return sResult;
}

bool PasswordListModel::insertRows(int iPosition, int iRows, const QModelIndex &oParent)
{
    qDebug() << __FUNCTION__;

    if (iRows==0) {
        return true;
    }

    QJsonArray oPasswordsJsonArray = this->fnGetPasswordsArray();

    beginInsertRows(QModelIndex(), iPosition, iPosition+iRows-1);

    for (int iRow = 0; iRow < iRows; ++iRow) {
        QJsonObject oJsonObject;
        oJsonObject["id"] = QDateTime::currentDateTime().toMSecsSinceEpoch(); //this->fnGenerateIndex();
        oJsonObject["createdAt"] = QDateTime::currentDateTime().toString("dd.MM.yyyy hh:mm:ss");

        qDebug() << "Created JSON object: " << oJsonObject << " at: " << iPosition;

        QJsonValue oJsonValue(oJsonObject);
        oPasswordsJsonArray.insert(iPosition, oJsonValue);
    }

    this->fnSetPasswordsArray(oPasswordsJsonArray);

    endInsertRows();

    this->fnSave();

    return true;
}

bool PasswordListModel::removeRows(int iPosition, int iRows, const QModelIndex &oParent)
{
    qDebug() << __FUNCTION__ << "iPosition:" << iPosition << "iRows:" << iRows << oParent;

    if (iRows==0) {
        return true;
    }

    QJsonArray oPasswordsJsonArray = this->fnGetPasswordsArray();

    beginRemoveRows(QModelIndex(), iPosition, iPosition+iRows-1);

    for (int iRow = iPosition; iRow < iPosition+iRows; ++iRow) {
        this->poPasswordChangeHistoryListModel->fnAddJsonObject("delete", oPasswordsJsonArray.at(iPosition).toObject());

        oPasswordsJsonArray.removeAt(iPosition);
        /*
        QJsonObject oJsonObject = this->poJsonArray->at(iRow).toObject();
        qDebug() << oJsonObject;
        oJsonObject["isDeleted"] = true;
        this->poJsonArray->replace(iRow, QJsonValue(oJsonObject));
        */
    }

    this->fnSetPasswordsArray(oPasswordsJsonArray);

    endRemoveRows();

    this->fnSave();

    return true;
}

QModelIndex PasswordListModel::index(int iRow, int iColumn, const QModelIndex &oParent) const
{
    qDebug() << __FUNCTION__;

    return createIndex(iRow, iColumn);
    //return QModelIndex();
}

QModelIndex PasswordListModel::parent(const QModelIndex &oChild) const
{
    qDebug() << __FUNCTION__;

    return QModelIndex();
}

int PasswordListModel::rowCount(const QModelIndex &oParent) const
{
    int iRows = this->fnGetPasswordsArray().size();

    qDebug() << __FUNCTION__ << iRows;

    return iRows;
}

int PasswordListModel::columnCount(const QModelIndex &oParent) const
{
    qDebug() << __FUNCTION__;

    Q_UNUSED(oParent);

    return 1;
}

bool PasswordListModel::hasChildren(const QModelIndex &oParent) const
{
    qDebug() << __FUNCTION__;

    return false;
}

void PasswordListModel::fnSetFilePath(QString aFilePath)
{
    qDebug() << __FUNCTION__;

    this->sFilePath = aFilePath;
}

QVariant PasswordListModel::fnGetFilePath()
{
    qDebug() << __FUNCTION__;

    return this->sFilePath;
}

void PasswordListModel::fnSetPassword(QString sPassword)
{
    qDebug() << __FUNCTION__;

    this->sPassword = sPassword;
}

QString PasswordListModel::fnGetPassword()
{
    qDebug() << __FUNCTION__;

    return this->sPassword;
}

void PasswordListModel::fnUpdate()
{
    qDebug() << __FUNCTION__;

    beginResetModel();
    endResetModel();
}

QVariant PasswordListModel::fnLoad()
{
    qDebug() << __FUNCTION__;

    beginResetModel();

    if (!this->fnFileExists()) {
        endResetModel();
        return 0;
    }

    QFile oFileObj(this->sFilePath);

    if (!oFileObj.open(QIODevice::ReadOnly)) {
        endResetModel();
        return -1;
    }

    Encrypter oEncrypter;
    QByteArray sResult;
    int iEncryptResult = oEncrypter.fnDecrypt(this->sPassword, oFileObj.readAll(), sResult);
    oFileObj.close();

    if (iEncryptResult<0) {
        return iEncryptResult*10;
    }

    QJsonDocument oJsonDocument = QJsonDocument::fromJson(sResult);

    if (!oJsonDocument.isObject()) {
        endResetModel();
        return -2;
    }

    *this->poJsonObject = oJsonDocument.object();

    endResetModel();

    return 1;
}

QVariant PasswordListModel::fnSave()
{
    qDebug() << __FUNCTION__;

    QFile oFileObj(this->sFilePath);

    if (!oFileObj.open(QIODevice::WriteOnly)) {
        return -1;
    }

    QJsonDocument oJsonDocument(*this->poJsonObject);

    Encrypter oEncrypter;
    QByteArray sResult;
    int iEncryptResult = oEncrypter.fnEncrypt(this->sPassword, oJsonDocument.toJson(), sResult);

    qDebug() << oJsonDocument.toJson();

    if (iEncryptResult<0) {
        oFileObj.close();
        return iEncryptResult*10;
    }

    oFileObj.write(sResult);

    oFileObj.close();

    return 1;
}

bool PasswordListModel::fnFileExists()
{
    qDebug() << __FUNCTION__;

    QFileInfo oFileInfo(this->sFilePath);

    return oFileInfo.exists() && oFileInfo.isFile();
}

void PasswordListModel::fnRemoveRow(int iIndex)
{
    qDebug() << __FUNCTION__ << iIndex;

    this->removeRows(iIndex, 1);
}

QVariant PasswordListModel::fnAddRow(QJsonObject oJsonObject)
{
    qDebug() << __FUNCTION__;

    int iSize = this->fnSize().toInt();

    this->insertRows(iSize, 1);

    iSize = this->fnSize().toInt();
    int iIndex = iSize-1;

    this->fnUpdateRow(iIndex, oJsonObject, false);

    return iIndex;
}

void PasswordListModel::fnUpdateRow(int iIndex, QJsonObject oNewJsonObject, bool bAddToHistory)
{
    qDebug() << __FUNCTION__;

    QJsonArray oPasswordsJsonArray = this->fnGetPasswordsArray();

    QJsonObject oJsonObject = oPasswordsJsonArray[iIndex].toObject();

    this->poPasswordChangeHistoryListModel->fnAddJsonObject("update", oJsonObject);

    foreach(const QString& sColumn, oNewJsonObject.keys()) {
        if (this->oColumns.contains(sColumn)) {
            oJsonObject[sColumn] = oNewJsonObject[sColumn];
        }
    }

    oPasswordsJsonArray.replace(iIndex, oJsonObject);

    this->fnSetPasswordsArray(oPasswordsJsonArray);

    this->fnSave();

    this->fnUpdate();
}

QVariant PasswordListModel::fnSize()
{
    qDebug() << __FUNCTION__;

    return this->fnGetPasswordsArray().size();
}

QVariant PasswordListModel::fnToByteArray()
{
    qDebug() << __FUNCTION__;

    QJsonArray oPasswordsJsonArray = this->fnGetPasswordsArray();

    QJsonDocument oJsonDocument(oPasswordsJsonArray);

    Encrypter oEncrypter;
    QByteArray sResult;
    int iEncryptResult = oEncrypter.fnEncrypt(this->sPassword, oJsonDocument.toJson(), sResult);
    qDebug() << "oEncrypter.fnEncrypt" << iEncryptResult;

    return sResult;
}

QVariant PasswordListModel::fnFromByteArray(QVariant oByteArray, QVariant iSyncMethod, bool bEncrypted)
{
    qDebug() << __FUNCTION__;

    beginResetModel();

    QJsonDocument oJsonDocument;
    int iEncryptResult = 1;

    if (bEncrypted) {
        Encrypter oEncrypter;
        QByteArray oResult;
        iEncryptResult = oEncrypter.fnDecrypt(this->sPassword, oByteArray.toByteArray(), oResult);
        qDebug() << "oEncrypter.fnDecrypt" << iEncryptResult;

        if (iEncryptResult != 1) {
            return iEncryptResult;
        }

        oJsonDocument = QJsonDocument::fromJson(oResult);
    } else {
        oJsonDocument = QJsonDocument::fromJson(oByteArray.toByteArray());
    }

    qDebug() << "iSyncMethod.toInt()" << iSyncMethod.toInt();

    if (iSyncMethod.toInt() == 0) {
        QJsonArray oPasswordsJsonArray = this->fnGetPasswordsArray();

        for (int iLocalIndex=0; iLocalIndex<oPasswordsJsonArray.size(); iLocalIndex++) {
            QJsonObject oLocalJsonObject = oPasswordsJsonArray[iLocalIndex].toObject();

            this->poPasswordChangeHistoryListModel->fnAddJsonObject("update", oLocalJsonObject);
        }

        this->fnSetPasswordsArray(oJsonDocument.array());
    }
    if (iSyncMethod.toInt() == 1 || iSyncMethod.toInt() == 2) {
        QJsonArray oPasswordsJsonArray = this->fnGetPasswordsArray();

        QJsonArray oRemoteJsonArray = oJsonDocument.array();

        qDebug() << "oRemoteJsonArray.size()" << oRemoteJsonArray.size();
        qDebug() << "this->poJsonArray->size()" << oPasswordsJsonArray.size();
        for (int iRemoteIndex=0; iRemoteIndex<oRemoteJsonArray.size(); iRemoteIndex++) {
            QJsonObject oRemoteJsonObject = oRemoteJsonArray[iRemoteIndex].toObject();

            /*
            if (oRemoteJsonObject["isDeleted"].toBool()) {
                continue;
            }
            */

            bool bFound = false;

            if (oPasswordsJsonArray.size()>0) {
                for (int iLocalIndex=0; iLocalIndex<oPasswordsJsonArray.size(); iLocalIndex++) {
                    qDebug() << oRemoteJsonObject << oPasswordsJsonArray[iLocalIndex].toObject() << (oRemoteJsonObject["id"] != oPasswordsJsonArray[iLocalIndex].toObject()["id"]);
                    QJsonObject oLocalJsonObject = oPasswordsJsonArray[iLocalIndex].toObject();

                    /*
                    if (oLocalJsonObject["isDeleted"].toBool()) {
                        continue;
                    }
                    */

                    if (oRemoteJsonObject["id"] == oLocalJsonObject["id"]) {
                        bFound = true;
                        if (iSyncMethod.toInt() == 1) {
                            oPasswordsJsonArray.replace(iLocalIndex, oRemoteJsonObject);
                            this->poPasswordChangeHistoryListModel->fnAddJsonObject("update", oLocalJsonObject);
                        }
                    }
                }
            }

            if (!bFound) {
                oPasswordsJsonArray.append(oRemoteJsonObject);
            }
        }

        this->fnSetPasswordsArray(oPasswordsJsonArray);
    }

    endResetModel();

    return iEncryptResult;
}

QVariant PasswordListModel::fnEncryptPassword()
{
    qDebug() << __FUNCTION__;

    Encrypter oEncrypter;
    QByteArray sResult;
    int iEncryptResult = oEncrypter.fnEncrypt(this->sPassword, this->sPassword.toUtf8(), sResult);
    qDebug() << "oEncrypter.fnEncryptPassword" << iEncryptResult;

    return sResult;
}

QVariant PasswordListModel::fnCheckPassword(QVariant oByteArray)
{
    qDebug() << __FUNCTION__;

    Encrypter oEncrypter;
    QByteArray oResult;
    int iEncryptResult = oEncrypter.fnDecrypt(this->sPassword, oByteArray.toByteArray(), oResult);
    qDebug() << "oEncrypter.fnCheckPassword" << iEncryptResult;

    if (iEncryptResult != 1) {
        return false;
    }

    return oResult == this->sPassword;
}

QVariant PasswordListModel::fnExport(QString sFilePath, int iType)
{
    //QString sFilePath = QUrl(sURL).toLocalFile();

    qDebug() << __FUNCTION__ << sFilePath;

    QFile oFileObj(sFilePath);

    if (!oFileObj.open(QIODevice::WriteOnly)) {
        qDebug() << "Can't open file";
        return -1;
    }

    QJsonArray oPasswordsJsonArray = this->fnGetPasswordsArray();

    if (iType==0) {
        QJsonDocument oJsonDocument(oPasswordsJsonArray);

        oFileObj.write(oJsonDocument.toJson());
    } else if (iType==1) {
        int iLength = oPasswordsJsonArray.size();

        QString sLine = "";
        for (int iIndex=0; iIndex<iLength; iIndex++) {
            QJsonObject oCurrentObject = oPasswordsJsonArray.at(iIndex).toObject();
            oFileObj.write("name:\n");
            sLine = oCurrentObject["name"].toString()+"\n";
            oFileObj.write(sLine.toUtf8());

            oFileObj.write("user:\n");
            sLine = oCurrentObject["user"].toString()+"\n";
            oFileObj.write(sLine.toUtf8());

            oFileObj.write("password:\n");
            sLine = oCurrentObject["password"].toString()+"\n";
            oFileObj.write(sLine.toUtf8());

            oFileObj.write("<<<additional\n");
            sLine = oCurrentObject["additional"].toString()+"\n";
            oFileObj.write(sLine.toUtf8());
            oFileObj.write("<<<additional\n");

            oFileObj.write("\n");
        }
    }

    oFileObj.close();

    return 1;
}

QVariant PasswordListModel::fnImport(QString sFilePath, int iSyncType)
{
    //QString sFilePath = QUrl(sURL).toLocalFile();

    qDebug() << __FUNCTION__ << sFilePath << iSyncType;

    beginResetModel();

    if (!this->fnFileExists()) {
        endResetModel();
        qDebug() << "File doesn't exist";
        return 0;
    }

    QFile oFileObj(sFilePath);

    if (!oFileObj.open(QIODevice::ReadOnly)) {
        endResetModel();
        qDebug() << "Can't open file";
        return -1;
    }

    int iResult = 1;

    if (iSyncType==0 || iSyncType==1 || iSyncType==2) {
        iResult = this->fnFromByteArray(oFileObj.readAll(), iSyncType, false).toInt();
    } else if (iSyncType==3 || iSyncType==4 || iSyncType==5) {

        if (iSyncType==3) {
            this->fnInit();
        }

        QChar oChar;
        QString sCurrentProperty = "";
        QString sCurrentPropertyEnd = "";
        QString sCurrentPropertyValue = "";
        bool bProperty = false;
        bool bMultiLineProperty = false;
        int iRowIndex = -1;
        int iMultiLineSC = 0;

        QString Lines = oFileObj.readAll();

        for (int iIndex=0; iIndex<Lines.size(); iIndex++) {
            oChar = Lines[iIndex];

            qDebug() << oChar;

            if (!bProperty && !bMultiLineProperty) {
                if ((oChar<'a' || oChar>'z') && oChar!=':' && oChar!='\n' && oChar!='<') {
                    continue;
                } else {
                    if (oChar=='<') {
                        iMultiLineSC++;
                        continue;
                    }
                    if (oChar>='a' && oChar<='z') {
                        sCurrentProperty += oChar;
                        continue;
                    }
                    if (oChar=='\n') {
                        if (iMultiLineSC==3) {
                            bMultiLineProperty = true;
                            qDebug() << "bMultiLineProperty" << sCurrentProperty;
                        } else if (iMultiLineSC==0) {
                            bProperty = true;
                            qDebug() << "bProperty" << sCurrentProperty;
                        }

                        iMultiLineSC = 0;
                        continue;
                    }
                }
            }
            if (bProperty) {
                if (oChar!='\n') {
                    sCurrentPropertyValue += oChar;
                } else {
                    qDebug() << "Save property " << sCurrentProperty << sCurrentPropertyValue;
                    if (sCurrentProperty=="name") {
                        if (iSyncType==3) {
                            iRowIndex = this->fnAddRow().toInt();
                        }
                        if (iSyncType==4 || iSyncType==5) {
                            iRowIndex = this->fnFind(sCurrentProperty, sCurrentPropertyValue).toInt();

                            if (iRowIndex==-1) {
                                iRowIndex = this->fnAddRow().toInt();
                            } else if (iSyncType==5) {
                                iRowIndex = -1;
                            }
                        }
                    }

                    if (sCurrentProperty=="name" || sCurrentProperty=="user" || sCurrentProperty=="password") {
                        if (iRowIndex!=-1) {
                            this->fnSetValue(iRowIndex, sCurrentProperty, sCurrentPropertyValue);
                        }
                    }

                    sCurrentProperty = "";
                    sCurrentPropertyValue = "";
                    bProperty = false;
                }
            }
            if (bMultiLineProperty) {
                if (oChar=='<') {
                    iMultiLineSC++;
                }
                if (iMultiLineSC>0) {
                    if (oChar=='\n' || iIndex==Lines.size()-1) {
                        qDebug() << "Compare " << sCurrentPropertyEnd << ("<<<"+sCurrentProperty);
                        if (sCurrentPropertyEnd=="<<<"+sCurrentProperty) {
                            qDebug() << "End of " << sCurrentProperty;
                            if (sCurrentProperty=="additional" && iRowIndex!=-1) {
                                this->fnSetValue(iRowIndex, sCurrentProperty, sCurrentPropertyValue);
                            }

                            iMultiLineSC = 0;
                            sCurrentProperty = "";
                            sCurrentPropertyValue = "";
                            sCurrentPropertyEnd = "";
                            bMultiLineProperty = false;
                        } else {
                            sCurrentPropertyEnd += oChar;
                            sCurrentPropertyValue += sCurrentPropertyEnd;
                            sCurrentPropertyEnd = "";
                        }
                    } else {
                        sCurrentPropertyEnd += oChar;
                    }
                } else {
                    sCurrentPropertyValue += oChar;
                }
            }
        }

    }

    endResetModel();

    this->fnSave();

    return iResult;
}

QVariant PasswordListModel::fnFind(QString sKey, QString sValue)
{
    qDebug() << __FUNCTION__;

    QJsonArray oPasswordsJsonArray = this->fnGetPasswordsArray();

    for (int iIndex = 0; iIndex<oPasswordsJsonArray.size(); iIndex++) {
        QJsonObject oJsonObject = oPasswordsJsonArray.at(iIndex).toObject();

        if (oJsonObject[sKey]==sValue) {
            return iIndex;
        }
    }

    return -1;
}

void PasswordListModel::fnSetValue(int iIndex, QString sKey, QString sValue)
{
    qDebug() << __FUNCTION__;

    QJsonArray oPasswordsJsonArray = this->fnGetPasswordsArray();

    QJsonObject oJsonObject = oPasswordsJsonArray[iIndex].toObject();

    oJsonObject[sKey] = sValue;

    oPasswordsJsonArray.replace(iIndex, oJsonObject);

    this->fnSetPasswordsArray(oPasswordsJsonArray);
}

void PasswordListModel::fnRestoreFromJsonObject(QJsonObject oJsonObject)
{
    qDebug() << __FUNCTION__;

    int iRecordIndex = this->fnFind("id", oJsonObject["id"].toString()).toInt();

    if (iRecordIndex==-1) {
        this->fnAddRow(oJsonObject);
    } else {
        this->fnUpdateRow(iRecordIndex, oJsonObject);
    }
}
