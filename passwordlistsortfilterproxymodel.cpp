#include "passwordlistsortfilterproxymodel.h"
#include "passwordlistmodel.h"
#include <QDebug>

PasswordListSortFilterProxyModel::PasswordListSortFilterProxyModel()
{

}

bool PasswordListSortFilterProxyModel::filterAcceptsRow(int iSourceRow, const QModelIndex &oSourceParent) const
{
    qDebug() << __FUNCTION__;

    QModelIndex iIndex = sourceModel()->index(iSourceRow, 0, oSourceParent);

    return !sourceModel()->data(iIndex, PasswordListModel::DeletedRole).toBool();
}
