#include "PasswordChangeHistoryListModel.h"

PasswordChangeHistoryListModel::PasswordChangeHistoryListModel(QObject *poParent):
    QAbstractListModel(poParent)
{
    qDebug() << __FUNCTION__;
}

PasswordChangeHistoryListModel::~PasswordChangeHistoryListModel()
{
    qDebug() << __FUNCTION__;
}

void PasswordChangeHistoryListModel::fnClearHistoryArray()
{
    (*this->poPasswordListModel->poJsonObject)["history"] = QJsonArray();
}

QJsonArray PasswordChangeHistoryListModel::fnGetHistoryArray() const
{
    return (*this->poPasswordListModel->poJsonObject)["history"].toArray();
}

void PasswordChangeHistoryListModel::fnSetHistoryArray(QJsonArray oJsonArray)
{
    (*this->poPasswordListModel->poJsonObject)["history"] = oJsonArray;
}

QHash<int, QByteArray> PasswordChangeHistoryListModel::roleNames() const
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
        { UpdatedAtRole, "updatedAt" },
        { TimestampRole, "timestamp" },
        { EventTypeRole, "eventType" }
    };
}

QVariant PasswordChangeHistoryListModel::data(const QModelIndex &oIndex, int iRole) const
{
    qDebug() << __FUNCTION__;

    QJsonArray oHistoryJsonArray = this->fnGetHistoryArray();

    if (!oIndex.isValid())
        return QVariant();

    if (oIndex.row() >= oHistoryJsonArray.size())
        return QVariant();

    QJsonObject oJsonObject = oHistoryJsonArray.at(oIndex.row()).toObject();

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
        return QString::number(oJsonObject["id"].toDouble(), 'f', 0);;
    } if (iRole == SourceIndexRole) {
        return oIndex.row();
    } if (iRole == CreatedAtRole) {
        return oJsonObject["createdAt"].toString();
    } if (iRole == UpdatedAtRole) {
        return oJsonObject["updatedAt"].toString();
    } if (iRole == TimestampRole) {
        return oJsonObject["timestamp"].toString();
    } if (iRole == EventTypeRole) {
        return oJsonObject["eventType"].toString();
    } else
        return QVariant();
}

bool PasswordChangeHistoryListModel::setData(const QModelIndex &oIndex, const QVariant &oValue, int iRole)
{
    qDebug() << __FUNCTION__;

    return false;
}

QVariant PasswordChangeHistoryListModel::headerData(int iSection, Qt::Orientation oOrientation, int iRole) const
{
    qDebug() << __FUNCTION__;

    if (iRole != Qt::DisplayRole)
         return QVariant();

     if (oOrientation == Qt::Horizontal)
         return QString("Column %1").arg(iSection);
     else
         return QString("Row %1").arg(iSection);
}

Qt::ItemFlags PasswordChangeHistoryListModel::flags(const QModelIndex &oIndex) const
{
    qDebug() << __FUNCTION__;

    if (!oIndex.isValid())
        return Qt::ItemIsEnabled;

    return QAbstractItemModel::flags(oIndex) | Qt::ItemIsEditable;
}

bool PasswordChangeHistoryListModel::insertRows(int iPosition, int iRows, const QModelIndex &oParent)
{
    qDebug() << __FUNCTION__;

    return false;
}

bool PasswordChangeHistoryListModel::removeRows(int iPosition, int iRows, const QModelIndex &oParent)
{
    qDebug() << __FUNCTION__;

    if (iRows==0) {
        return true;
    }

    QJsonArray oHistoryJsonArray = this->fnGetHistoryArray();

    beginRemoveRows(QModelIndex(), iPosition, iPosition+iRows-1);

    for (int iRow = iPosition; iRow < iPosition+iRows; ++iRow) {
        oHistoryJsonArray.removeAt(iPosition);
        /*
        QJsonObject oJsonObject = this->poJsonArray->at(iRow).toObject();
        qDebug() << oJsonObject;
        oJsonObject["isDeleted"] = true;
        this->poJsonArray->replace(iRow, QJsonValue(oJsonObject));
        */
    }

    this->fnSetHistoryArray(oHistoryJsonArray);

    endRemoveRows();

    this->poPasswordListModel->fnSave();

    return true;
}

QModelIndex PasswordChangeHistoryListModel::index(int iRow, int iColumn, const QModelIndex &oParent) const
{
    qDebug() << __FUNCTION__;

    return createIndex(iRow, iColumn);
}

QModelIndex PasswordChangeHistoryListModel::parent(const QModelIndex &oChild) const
{
    qDebug() << __FUNCTION__;

    return QModelIndex();
}

int PasswordChangeHistoryListModel::rowCount(const QModelIndex &oParent) const
{
    int iRows = this->fnGetHistoryArray().size();

    qDebug() << __FUNCTION__ << iRows;

    return iRows;
}

int PasswordChangeHistoryListModel::columnCount(const QModelIndex &oParent) const
{
    qDebug() << __FUNCTION__;

    Q_UNUSED(oParent);

    return 1;
}

bool PasswordChangeHistoryListModel::hasChildren(const QModelIndex &oParent) const
{
    qDebug() << __FUNCTION__;

    return false;
}

void PasswordChangeHistoryListModel::fnAddJsonObject(QString sEventType, QJsonObject oJsonObject)
{
    qDebug() << __FUNCTION__;

    QJsonArray oHistoryJsonArray = this->fnGetHistoryArray();

    beginInsertRows(QModelIndex(), 0, 0);

    oJsonObject["timestamp"] = QDateTime::currentDateTime().toString("dd.MM.yyyy hh:mm:ss");
    oJsonObject["eventType"] = sEventType;

    QJsonValue oJsonValue(oJsonObject);

    oHistoryJsonArray.insert(0, oJsonValue);

    this->fnSetHistoryArray(oHistoryJsonArray);

    endInsertRows();

    //this->poPasswordListModel->fnSave();
}

void PasswordChangeHistoryListModel::fnClear()
{
    beginResetModel();

    this->fnClearHistoryArray();

    endResetModel();
}

void PasswordChangeHistoryListModel::fnRemoveRow(int iIndex)
{
    qDebug() << __FUNCTION__ << iIndex;

    this->removeRows(iIndex, 1);
}

void PasswordChangeHistoryListModel::fnRestore(int iIndex)
{
     qDebug() << __FUNCTION__ << iIndex;

     QJsonArray oHistoryJsonArray = this->fnGetHistoryArray();

     QJsonObject oJsonObject = oHistoryJsonArray.at(iIndex).toObject();

     this->poPasswordListModel->fnRestoreFromJsonObject(oJsonObject);
}
