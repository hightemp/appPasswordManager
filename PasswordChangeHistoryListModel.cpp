#include "PasswordChangeHistoryListModel.h"

PasswordChangeHistoryListModel::PasswordChangeHistoryListModel(QJsonObject *poJsonObject, QObject *poParent): poJsonObject(poJsonObject), poParent(poParent)
{

}

PasswordChangeHistoryListModel::~PasswordChangeHistoryListModel()
{

}

QHash<int, QByteArray> PasswordChangeHistoryListModel::roleNames() const
{

}

QVariant PasswordChangeHistoryListModel::data(const QModelIndex &oIndex, int iRole) const
{

}

bool PasswordChangeHistoryListModel::setData(const QModelIndex &oIndex, const QVariant &oValue, int iRole)
{

}

QVariant PasswordChangeHistoryListModel::headerData(int iSection, Qt::Orientation oOrientation, int iRole) const
{

}

Qt::ItemFlags PasswordChangeHistoryListModel::flags(const QModelIndex &oIndex) const
{

}

bool PasswordChangeHistoryListModel::insertRows(int iPosition, int iRows, const QModelIndex &oParent)
{

}

bool PasswordChangeHistoryListModel::removeRows(int iPosition, int iRows, const QModelIndex &oParent)
{

}

QModelIndex PasswordChangeHistoryListModel::index(int iRow, int iColumn, const QModelIndex &oParent) const
{

}

QModelIndex PasswordChangeHistoryListModel::parent(const QModelIndex &oChild) const
{

}

int PasswordChangeHistoryListModel::rowCount(const QModelIndex &oParent) const
{

}

int PasswordChangeHistoryListModel::columnCount(const QModelIndex &oParent) const
{

}

bool PasswordChangeHistoryListModel::hasChildren(const QModelIndex &oParent) const
{

}
