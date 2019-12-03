#ifndef PASSWORDCHANGEHISTORYLISTMODEL_H
#define PASSWORDCHANGEHISTORYLISTMODEL_H

#include <QAbstractItemModel>
#include <QJsonArray>
#include <QJsonObject>
#include <QException>
#include <QDebug>
#include "PasswordListModel.h"

class PasswordListModel;

class PasswordChangeHistoryListModel : public QAbstractListModel
{
    Q_OBJECT
    Q_ENUMS(PasswordChangeHistoryListModelRoles)

public:
    PasswordListModel* poPasswordListModel = nullptr;

public:

    enum PasswordChangeHistoryListModelRoles {
        NameRole = Qt::UserRole + 1,
        UserRole,
        PasswordRole,
        IsDeletedRole,
        AdditionalRole,
        IDRole,
        SourceIndexRole,
        CreatedAtRole,
        UpdatedAtRole,
        TimestampRole,
        EventTypeRole
    };

    explicit PasswordChangeHistoryListModel(QObject *poParent = nullptr);
    ~PasswordChangeHistoryListModel() override;

    void fnClearHistoryArray();
    QJsonArray fnGetHistoryArray() const;
    void fnSetHistoryArray(QJsonArray oJsonArray);
    QHash<int,QByteArray> roleNames() const override;
    QVariant data(const QModelIndex &oIndex, int iRole) const override;
    bool setData(const QModelIndex &oIndex, const QVariant &oValue, int iRole = Qt::EditRole) override;
    QVariant headerData(int iSection, Qt::Orientation oOrientation, int iRole = Qt::DisplayRole) const override;
    Qt::ItemFlags flags(const QModelIndex &oIndex) const override;
    bool insertRows(int iPosition, int iRows, const QModelIndex &oParent = QModelIndex()) override;
    bool removeRows(int iPosition, int iRows, const QModelIndex &oParent = QModelIndex()) override;
    QModelIndex index(int iRow, int iColumn, const QModelIndex &oParent = QModelIndex()) const override;
    QModelIndex parent(const QModelIndex &oChild) const override;
    int rowCount(const QModelIndex &oParent = QModelIndex()) const override;
    int columnCount(const QModelIndex &oParent = QModelIndex()) const override;
    bool hasChildren(const QModelIndex &oParent) const override;

public slots:
    void fnAddJsonObject(QString sEventType, QJsonObject oJsonObject);
    void fnClear();
    void fnRemoveRow(int iIndex);
    void fnRestore(int iIndex);
};

#endif // PASSWORDCHANGEHISTORYLISTMODEL_H
