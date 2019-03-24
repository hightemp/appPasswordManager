#ifndef PASSWORDCHANGEHISTORYLISTSORTFILTERPROXYMODEL_H
#define PASSWORDCHANGEHISTORYLISTSORTFILTERPROXYMODEL_H

#include <QModelIndex>
#include <QSortFilterProxyModel>

class PasswordChangeHistoryListSortFilterProxyModel : public QSortFilterProxyModel
{
public:
    bool filterAcceptsRow(int iSourceRow, const QModelIndex &oSourceParent) const override;
};

#endif // PASSWORDCHANGEHISTORYLISTSORTFILTERPROXYMODEL_H
