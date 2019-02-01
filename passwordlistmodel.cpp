#include "passwordlistmodel.h"
#include "encrypter.h"

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
        { DeletedRole, "deleted" }
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
    } if (iRole == DeletedRole) {
        return oJsonObject["deleted"].toBool();
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

bool PasswordListModel::insertRows(int iPosition, int iRows, const QModelIndex &oParent)
{
    qDebug() << __FUNCTION__;
    beginInsertRows(QModelIndex(), iPosition, iPosition+iRows-1);

    for (int iRow = 0; iRow < iRows; ++iRow) {
        QJsonValue oJsonValue("");
        this->poJsonArray->insert(iPosition, oJsonValue);
    }

    endInsertRows();
    this->fnSave();
    return true;
}

bool PasswordListModel::removeRows(int iPosition, int iRows, const QModelIndex &oParent)
{
    qDebug() << __FUNCTION__;
    beginRemoveRows(QModelIndex(), iPosition, iPosition+iRows-1);

    for (int iRow = iPosition; iRow < iPosition+iRows; ++iRow) {
        //this->poJsonArray->removeAt(iPosition);
        QJsonObject oJsonObject = this->poJsonArray->at(iRow).toObject();
        oJsonObject["deleted"] = true;
        this->poJsonArray->replace(iRow, QJsonValue(oJsonObject));
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

void PasswordListModel::fnSetPassword(QVariant sPassword)
{
    qDebug() << __FUNCTION__;
    this->sPassword = sPassword.toString();
}

void PasswordListModel::fnSetPassword(QString sPassword)
{
    qDebug() << __FUNCTION__;
    this->sPassword = sPassword;
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
    this->removeRows(iIndex, 1);
}

QVariant PasswordListModel::fnAddRow()
{
    this->insertRows(this->poJsonArray->size(), 1);

    return this->poJsonArray->size()-1;
}

QVariant PasswordListModel::fnSize()
{
    return this->poJsonArray->size();
}

QVariant PasswordListModel::fnToByteArray()
{
    QJsonDocument oJsonDocument(*this->poJsonArray);

    Encrypter oEncrypter;
    QByteArray sResult;
    int iEncryptResult = oEncrypter.fnEncrypt(this->sPassword, oJsonDocument.toJson(), sResult);

    return sResult;
}

void PasswordListModel::fnFromByteArray(QVariant oByteArray, QVariant iSyncMethod)
{
    beginResetModel();

    Encrypter oEncrypter;
    QByteArray sResult;
    int iEncryptResult = oEncrypter.fnDecrypt(this->sPassword, oByteArray.toByteArray(), sResult);

    QJsonDocument oJsonDocument = QJsonDocument::fromJson(sResult);

    if (iSyncMethod.toInt() == 0) {
        *this->poJsonArray = oJsonDocument.array();
    }

    endResetModel();
}
