#include "PasswordListModel.h"
#include "Encrypter.h"

PasswordListModel::PasswordListModel(QObject *poParent) : QAbstractListModel(poParent)
{
    qDebug() << __FUNCTION__;
    this->poJsonArray = new QJsonArray();
}

PasswordListModel::~PasswordListModel()
{
    qDebug() << __FUNCTION__;
    delete this->poJsonArray;
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

    if (!oIndex.isValid())
        return QVariant();

    if (oIndex.row() >= this->poJsonArray->size())
        return QVariant();

    QJsonObject oJsonObject = this->poJsonArray->at(oIndex.row()).toObject();

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
    if (oIndex.isValid() /*&& iRole == Qt::EditRole*/) {
        if (oIndex.row()<this->poJsonArray->size()) {
            QJsonObject oJsonObject = this->poJsonArray->at(oIndex.row()).toObject();
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
            this->poJsonArray->replace(oIndex.row(), oJsonValue);
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
    beginInsertRows(QModelIndex(), iPosition, iPosition+iRows-1);

    for (int iRow = 0; iRow < iRows; ++iRow) {
        QJsonObject oJsonObject;
        oJsonObject["id"] = QDateTime::currentDateTime().toMSecsSinceEpoch(); //this->fnGenerateIndex();
        oJsonObject["createdAt"] = QDateTime::currentDateTime().toString("dd.MM.yyyy hh:mm:ss");
        QJsonValue oJsonValue(oJsonObject);
        this->poJsonArray->insert(iPosition, oJsonValue);
    }

    endInsertRows();
    this->fnSave();
    return true;
}

bool PasswordListModel::removeRows(int iPosition, int iRows, const QModelIndex &oParent)
{
    qDebug() << __FUNCTION__ << "iPosition:" << iPosition << "iRows:" << iRows << oParent;
    beginRemoveRows(QModelIndex(), iPosition, iPosition+iRows-1);

    for (int iRow = iPosition; iRow < iPosition+iRows; ++iRow) {
        this->poJsonArray->removeAt(iPosition);
        /*
        QJsonObject oJsonObject = this->poJsonArray->at(iRow).toObject();
        qDebug() << oJsonObject;
        oJsonObject["isDeleted"] = true;
        this->poJsonArray->replace(iRow, QJsonValue(oJsonObject));
        */
    }

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
    int iRows = this->poJsonArray->size();
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
    this->sFilePath = aFilePath;
}

QVariant PasswordListModel::fnGetFilePath()
{
    return this->sFilePath;
}

void PasswordListModel::fnSetPassword(QString sPassword)
{
    qDebug() << __FUNCTION__;
    this->sPassword = sPassword;
}

QString PasswordListModel::fnGetPassword()
{
    return this->sPassword;
}

void PasswordListModel::fnUpdate()
{
    beginResetModel();
    endResetModel();
}

QVariant PasswordListModel::fnLoad()
{
    qDebug() << __FUNCTION__;
    if (this->poJsonArray != nullptr) {
        delete this->poJsonArray;
    }

    beginResetModel();
    this->poJsonArray = new QJsonArray;

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

    if (!oJsonDocument.isArray()) {
        endResetModel();
        return -2;
    }

    *this->poJsonArray = oJsonDocument.array();

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

    QJsonDocument oJsonDocument(*this->poJsonArray);

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

QVariant PasswordListModel::fnAddRow()
{
    qDebug() << __FUNCTION__;
    this->insertRows(this->poJsonArray->size(), 1);

    return this->poJsonArray->size()-1;
}

QVariant PasswordListModel::fnSize()
{
    qDebug() << __FUNCTION__;
    return this->poJsonArray->size();
}

QVariant PasswordListModel::fnToByteArray()
{
    qDebug() << __FUNCTION__;
    QJsonDocument oJsonDocument(*this->poJsonArray);

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
        delete this->poJsonArray;

        *this->poJsonArray = oJsonDocument.array();
    }
    if (iSyncMethod.toInt() == 1 || iSyncMethod.toInt() == 2) {
        QJsonArray oRemoteJsonArray = oJsonDocument.array();

        qDebug() << "oRemoteJsonArray.size()" << oRemoteJsonArray.size();
        qDebug() << "this->poJsonArray->size()" << this->poJsonArray->size();
        for (int iRemoteIndex=0; iRemoteIndex<oRemoteJsonArray.size(); iRemoteIndex++) {
            QJsonObject oRemoteJsonObject = oRemoteJsonArray[iRemoteIndex].toObject();

            /*
            if (oRemoteJsonObject["isDeleted"].toBool()) {
                continue;
            }
            */

            bool bFound = false;

            if (this->poJsonArray->size()>0) {
                for (int iLocalIndex=0; iLocalIndex<this->poJsonArray->size(); iLocalIndex++) {
                    qDebug() << oRemoteJsonObject << (*this->poJsonArray)[iLocalIndex].toObject() << (oRemoteJsonObject["id"] != (*this->poJsonArray)[iLocalIndex].toObject()["id"]);
                    QJsonObject oLocalJsonObject = (*this->poJsonArray)[iLocalIndex].toObject();

                    /*
                    if (oLocalJsonObject["isDeleted"].toBool()) {
                        continue;
                    }
                    */

                    if (oRemoteJsonObject["id"] == oLocalJsonObject["id"]) {
                        bFound = true;
                        if (iSyncMethod.toInt() == 1) {
                            this->poJsonArray->replace(iLocalIndex, oRemoteJsonObject);
                        }
                    }
                }
            }

            if (!bFound) {
                this->poJsonArray->append(oRemoteJsonObject);
            }
        }
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

QVariant PasswordListModel::fnExport(QString sURL, int iType)
{
    QString sFilePath = QUrl(sURL).toLocalFile();

    qDebug() << __FUNCTION__ << sFilePath;

    QFile oFileObj(sFilePath);

    if (!oFileObj.open(QIODevice::WriteOnly)) {
        qDebug() << "Can't open file";
        return -1;
    }

    if (iType==0) {
        QJsonDocument oJsonDocument(*this->poJsonArray);

        oFileObj.write(oJsonDocument.toJson());
    } else if (iType==1) {
        int iLength = (*this->poJsonArray).size();
        QString sLine = "";
        for (int iIndex=0; iIndex<iLength; iIndex++) {
            QJsonObject oCurrentObject = (*this->poJsonArray).at(iIndex).toObject();
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

QVariant PasswordListModel::fnImport(QString sURL, int iType)
{
    QString sFilePath = QUrl(sURL).toLocalFile();

    qDebug() << __FUNCTION__ << sFilePath;

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

    beginResetModel();

    if (iType==0 || iType==1 || iType==2) {
        iResult = this->fnFromByteArray(oFileObj.readAll(), iType, false).toInt();
    } else if (iType==3 || iType==4 || iType==5) {

        if (iType==3) {
            delete this->poJsonArray;

            this->poJsonArray = new QJsonArray();
        }

        char cChar;
        QString sCurrentProperty = "";
        QString sCurrentPropertyEnd = "";
        QString sCurrentPropertyValue = "";
        bool bProperty = false;
        bool bMultiLineProperty = false;
        int iRowIndex = -1;
        int iMultiLineSC = 0;

        while (oFileObj.getChar(&cChar)) {
            if (!bProperty && !bMultiLineProperty) {
                if (iMultiLineSC>0) {
                    if (cChar!='<') {
                        iMultiLineSC = 0;
                    }
                }
                if ((cChar<'a' || cChar>'z') && cChar!=':' && cChar!='\n' && cChar!='<') {
                    continue;
                } else {
                    if (cChar=='<') {
                        iMultiLineSC++;
                        continue;
                    }
                    if (cChar>='a' || cChar<='z') {
                        sCurrentProperty += cChar;
                        continue;
                    }
                    if (cChar=='\n') {
                        if (iMultiLineSC==3) {
                            iMultiLineSC=0;
                            bMultiLineProperty = true;
                        } else if (iMultiLineSC==0) {
                            bProperty = true;
                        }
                        continue;
                    }
                }
            }
            if (bProperty) {
                if (cChar!='\n') {
                    sCurrentPropertyValue += cChar;
                } else {
                    if (sCurrentProperty=="name") {
                        if (iType==3) {
                            this->fnAddRow();
                            iRowIndex = this->fnSize().toInt()-1;
                        }
                        if (iType==4 || iType==5) {
                            iRowIndex = this->fnFind(sCurrentProperty, sCurrentPropertyValue).toInt();

                            if (iRowIndex==-1) {
                                this->fnAddRow();
                                iRowIndex = this->fnSize().toInt()-1;
                            } else if (iType==5) {
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
                if (iMultiLineSC>0) {
                    if (cChar!='<') {
                        iMultiLineSC = 0;
                        sCurrentPropertyValue += sCurrentPropertyEnd;
                        sCurrentPropertyEnd = "";
                    }
                }
                if (cChar=='<') {
                    iMultiLineSC++;
                }
                if (iMultiLineSC>0) {
                    if (cChar=='\n') {
                        if (sCurrentPropertyEnd=="<<<"+sCurrentProperty) {
                            if (sCurrentProperty=="additional" && iRowIndex!=-1) {
                                this->fnSetValue(iRowIndex, sCurrentProperty, sCurrentPropertyValue);
                            }
                            bMultiLineProperty = false;
                        } else {
                            sCurrentPropertyEnd += cChar;
                            sCurrentPropertyValue += sCurrentPropertyEnd;
                            sCurrentPropertyEnd = "";
                        }
                    } else {
                        sCurrentPropertyEnd += cChar;
                    }
                } else {
                    sCurrentPropertyValue += cChar;
                }
            }
        }

    }

    endResetModel();

    return iResult;
}

QVariant PasswordListModel::fnFind(QString sKey, QString sValue)
{
    for (int iIndex = 0; iIndex<this->poJsonArray->size(); iIndex++) {
        QJsonObject oJsonObject = this->poJsonArray->at(iIndex).toObject();

        if (oJsonObject[sKey]==sValue) {
            return iIndex;
        }
    }

    return -1;
}

void PasswordListModel::fnSetValue(int iIndex, QString sKey, QString sValue)
{
    QJsonObject oJsonObject = (*this->poJsonArray)[iIndex].toObject();

    oJsonObject[sKey] = sValue;

    this->poJsonArray->replace(iIndex, oJsonObject);
}
