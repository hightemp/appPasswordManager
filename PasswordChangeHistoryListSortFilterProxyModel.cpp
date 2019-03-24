#include "PasswordChangeHistoryListSortFilterProxyModel.h"

#include "PasswordChangeHistoryListModel.h"
#include <QDebug>

bool PasswordChangeHistoryListSortFilterProxyModel::filterAcceptsRow(int iSourceRow, const QModelIndex &oSourceParent) const
{
    qDebug() << __FUNCTION__ << this->filterRegExp();

    QModelIndex iIndex = this->sourceModel()->index(iSourceRow, 0, oSourceParent);

    return !this->sourceModel()->data(iIndex, PasswordChangeHistoryListModel::IsDeletedRole).toBool()
            && (
                this->sourceModel()->data(iIndex, PasswordChangeHistoryListModel::NameRole).toString().contains(this->filterRegExp())
                || this->sourceModel()->data(iIndex, PasswordChangeHistoryListModel::UserRole).toString().contains(this->filterRegExp())
                || this->sourceModel()->data(iIndex, PasswordChangeHistoryListModel::PasswordRole).toString().contains(this->filterRegExp())
                || this->sourceModel()->data(iIndex, PasswordChangeHistoryListModel::AdditionalRole).toString().contains(this->filterRegExp())
            );
}

