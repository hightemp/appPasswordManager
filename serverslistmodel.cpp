#include "serverslistmodel.h"
#include "encrypter.h"

ServersListModel::ServersListModel(SettingsModel* poSettingsModel, QObject *poParent) : QAbstractListModel(poParent)
{
    qDebug() << __FUNCTION__;
    this->poSettingsModel = poSettingsModel;
}

ServersListModel::~ServersListModel()
{
    qDebug() << __FUNCTION__;
}

QHash<int,QByteArray> ServersListModel::roleNames() const
{
    qDebug() << __FUNCTION__;
    return {
        { IsEnabledRole, "isEnabled" },
        { HostRole, "host" },
        { PortRole, "port" }
    };
}

QVariant ServersListModel::data(const QModelIndex &oIndex, int iRole) const
{
    qDebug() << __FUNCTION__;

    if (!oIndex.isValid())
        return QVariant();

    QJsonArray oServersJsonArray = this->poSettingsModel->fnGetJsonArrayValue("servers");

    if (oIndex.row() >= oServersJsonArray.size())
        return QVariant();

    QJsonObject oJsonObject = oServersJsonArray.at(oIndex.row()).toObject();

    if (iRole == IsEnabledRole) {
        return oJsonObject["isEnabled"].toBool();
    } if (iRole == HostRole) {
        return oJsonObject["host"].toString();
    } if (iRole == PortRole) {
        return oJsonObject["port"].toString();
    } else
        return QVariant();
}

bool ServersListModel::setData(const QModelIndex &oIndex, const QVariant &oValue, int iRole)
{
    qDebug() << __FUNCTION__;
    if (oIndex.isValid() /*&& iRole == Qt::EditRole*/) {
        QJsonArray oServersJsonArray = this->poSettingsModel->fnGetJsonArrayValue("servers");

        if (oIndex.row() < oServersJsonArray.size()) {
            QJsonObject oJsonObject = oServersJsonArray.at(oIndex.row()).toObject();

            if (iRole == IsEnabledRole) {
                oJsonObject["isEnabled"] = oValue.toBool();
            }
            if (iRole == HostRole) {
                oJsonObject["host"] = oValue.toString();
            }
            if (iRole == PortRole) {
                oJsonObject["port"] = oValue.toString();
            }

            QJsonValue oJsonValue(oJsonObject);
            oServersJsonArray.replace(oIndex.row(), oJsonValue);
            this->poSettingsModel->fnUpdateJsonArrayValue("servers", oServersJsonArray);
        }
        emit dataChanged(oIndex, oIndex, { iRole });
        this->fnSave();
        return true;
    }
    return false;
}

QVariant ServersListModel::headerData(
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


Qt::ItemFlags ServersListModel::flags(const QModelIndex &oIndex) const
{
    qDebug() << __FUNCTION__;
    if (!oIndex.isValid())
        return Qt::ItemIsEnabled;

    return QAbstractItemModel::flags(oIndex) | Qt::ItemIsEditable;
}

bool ServersListModel::insertRows(int iPosition, int iRows, const QModelIndex &oParent)
{
    qDebug() << __FUNCTION__;
    beginInsertRows(QModelIndex(), iPosition, iPosition+iRows-1);

    QJsonArray oServersJsonArray = this->poSettingsModel->fnGetJsonArrayValue("servers");

    for (int iRow = 0; iRow < iRows; ++iRow) {
        QJsonObject oJsonObject;
        QJsonValue oJsonValue(oJsonObject);
        oServersJsonArray.insert(iPosition, oJsonValue);
    }

    this->poSettingsModel->fnUpdateJsonArrayValue("servers", oServersJsonArray);

    endInsertRows();
    this->fnSave();
    return true;
}

bool ServersListModel::removeRows(int iPosition, int iRows, const QModelIndex &oParent)
{
    qDebug() << __FUNCTION__;
    beginRemoveRows(QModelIndex(), iPosition, iPosition+iRows-1);

    QJsonArray oServersJsonArray = this->poSettingsModel->fnGetJsonArrayValue("servers");

    for (int iRow = iPosition; iRow < iPosition+iRows; ++iRow) {
        oServersJsonArray.removeAt(iPosition);
    }

    this->poSettingsModel->fnUpdateJsonArrayValue("servers", oServersJsonArray);

    endRemoveRows();
    this->fnSave();
    return true;
}

QModelIndex ServersListModel::index(int iRow, int iColumn, const QModelIndex &oParent) const
{
    qDebug() << __FUNCTION__;
    return createIndex(iRow, iColumn);
    //return QModelIndex();
}

QModelIndex ServersListModel::parent(const QModelIndex &oChild) const
{
    qDebug() << __FUNCTION__;
    return QModelIndex();
}

int ServersListModel::rowCount(const QModelIndex &oParent) const
{
    int iRows = this->poSettingsModel->fnGetJsonArrayValue("servers").size();
    qDebug() << __FUNCTION__ << iRows;
    return iRows;
}

int ServersListModel::columnCount(const QModelIndex &oParent) const
{
    qDebug() << __FUNCTION__;
    Q_UNUSED(oParent);
    return 1;
}

bool ServersListModel::hasChildren(const QModelIndex &oParent) const
{
    qDebug() << __FUNCTION__;
    return false;
}

void ServersListModel::fnUpdate()
{
    beginResetModel();
    endResetModel();
}

QVariant ServersListModel::fnLoad()
{
    qDebug() << __FUNCTION__;

    return this->poSettingsModel->fnLoad();
}

QVariant ServersListModel::fnSave()
{
    qDebug() << __FUNCTION__;

    return this->poSettingsModel->fnSave();
}

void ServersListModel::fnRemoveRow(int iIndex)
{
    this->removeRows(iIndex, 1);
}

QVariant ServersListModel::fnAddRow()
{
    this->insertRows(this->rowCount(), 1);

    return this->rowCount()-1;
}

QVariant ServersListModel::fnSize()
{
    return this->rowCount();
}

QVariant ServersListModel::fnGetStringValue(int iIndex, QVariant sName, QVariant sDefaultValue)
{
    QJsonObject oJsonObject = this->poSettingsModel->fnGetJsonArrayValue("servers")[iIndex].toObject();
    QString sResult = oJsonObject[sName.toString()].toString();
    return sResult.isEmpty() ? sDefaultValue : sResult;
}

QVariant ServersListModel::fnGetBoolValue(int iIndex, QVariant sName)
{
    QJsonObject oJsonObject = this->poSettingsModel->fnGetJsonArrayValue("servers")[iIndex].toObject();
    return oJsonObject[sName.toString()].toBool();
}
