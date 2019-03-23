#ifndef ServersListModel_H
#define ServersListModel_H

#include <QAbstractItemModel>
#include <QJsonArray>
#include <QJsonObject>
#include <QFile>
#include <QException>
#include <QDebug>
#include <QFileInfo>
#include <QJsonDocument>
#include "SettingsModel.h"

class ServersListModel : public QAbstractListModel
{
    Q_OBJECT
    Q_ENUMS(ServersListModelRoles)

protected:
    QString sFilePath;
    QString sPassword;
    SettingsModel* poSettingsModel;

public:

    enum ServersListModelRoles {
        IsEnabledRole = Qt::UserRole + 1,
        HostRole,
        PortRole
    };

    explicit ServersListModel(SettingsModel* poSettingsModel, QObject *poParent = nullptr);
    ~ServersListModel() override;

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
    void fnUpdate();
    QVariant fnLoad();
    QVariant fnSave();
    QVariant fnAddRow();
    void fnRemoveRow(int iIndex);
    QVariant fnSize();
    QVariant fnGetStringValue(int iIndex, QVariant sName, QVariant sDefaultValue="");
    QVariant fnGetBoolValue(int iIndex, QVariant sName);
};

#endif // ServersListModel_H
