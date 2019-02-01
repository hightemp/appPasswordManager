#ifndef PASSWORDLISTSORTFILTERPROXYMODEL_H
#define PASSWORDLISTSORTFILTERPROXYMODEL_H

#include <QModelIndex>
#include <QSortFilterProxyModel>

class PasswordListSortFilterProxyModel : public QSortFilterProxyModel
{
public:
    PasswordListSortFilterProxyModel();

    bool filterAcceptsRow(int iSourceRow, const QModelIndex &oSourceParent) const override;

};

#endif // PASSWORDLISTSORTFILTERPROXYMODEL_H
