#include "PasswordListSortFilterProxyModel.h"
#include "PasswordListModel.h"
#include <QDebug>

bool PasswordListSortFilterProxyModel::filterAcceptsRow(int iSourceRow, const QModelIndex &oSourceParent) const
{
    qDebug() << __FUNCTION__ << this->filterRegExp();

    QModelIndex iIndex = this->sourceModel()->index(iSourceRow, 0, oSourceParent);

    return !this->sourceModel()->data(iIndex, PasswordListModel::IsDeletedRole).toBool()
            && (
                this->sourceModel()->data(iIndex, PasswordListModel::NameRole).toString().contains(this->filterRegExp())
                || this->sourceModel()->data(iIndex, PasswordListModel::UserRole).toString().contains(this->filterRegExp())
                || this->sourceModel()->data(iIndex, PasswordListModel::PasswordRole).toString().contains(this->filterRegExp())
                || this->sourceModel()->data(iIndex, PasswordListModel::AdditionalRole).toString().contains(this->filterRegExp())
            );
}

