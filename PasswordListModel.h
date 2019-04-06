#ifndef PASSWORDLISTMODEL_H
#define PASSWORDLISTMODEL_H

#include <QAbstractItemModel>
#include <QJsonArray>
#include <QJsonObject>
#include <QFile>
#include <QException>
#include <QDebug>
#include <QFileInfo>
#include <QJsonDocument>
#include <QDateTime>
#include <QUrl>
#include "PasswordChangeHistoryListModel.h"

class PasswordChangeHistoryListModel;

class PasswordListModel : public QAbstractListModel
{
    Q_OBJECT
    Q_ENUMS(PasswordListModelRoles)

public:
    QJsonObject* poJsonObject = nullptr;
    QString sFilePath;
    QString sPassword;
    PasswordChangeHistoryListModel* poPasswordChangeHistoryListModel = nullptr;

    QStringList oColumns = {
        "name",
        "user",
        "password",
        "isDeleted",
        "additional",
        "id",
        "sourceIndex",
        "createdAt",
        "updatedAt"
    };
public:

    enum PasswordListModelRoles {
        NameRole = Qt::UserRole + 1,
        UserRole,
        PasswordRole,
        IsDeletedRole,
        AdditionalRole,
        IDRole,
        SourceIndexRole,
        CreatedAtRole,
        UpdatedAtRole
    };

    explicit PasswordListModel(QObject *poParent = nullptr);
    ~PasswordListModel() override;

    void fnInit();
    void fnClearPasswordsArray();
    QJsonArray fnGetPasswordsArray() const;
    void fnSetPasswordsArray(QJsonArray oJsonArray);
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
    QString fnGenerateIndex(int iLength=10);
    void fnSetFilePath(QString aFilePath);
    QVariant fnGetFilePath();
    void fnSetPassword(QString sPassword);
    QString fnGetPassword();
    void fnUpdate();
    QVariant fnLoad();
    QVariant fnSave();
    bool fnFileExists();
    QVariant fnAddRow(QJsonObject oJsonObject={});
    void fnUpdateRow(int iIndex, QJsonObject oNewJsonObject, bool bAddToHistory=true);
    void fnRemoveRow(int iIndex);
    QVariant fnSize();
    QVariant fnToByteArray();
    QVariant fnFromByteArray(QVariant oByteArray, QVariant iSyncMethod, bool bEncrypted = true);
    QVariant fnEncryptPassword();
    QVariant fnCheckPassword(QVariant oByteArray);
    QVariant fnExport(QString sURL, int iType);
    QVariant fnImport(QString sURL, int iSyncType);
    QVariant fnFind(QString sKey, QString sValue);
    void fnSetValue(int iIndex, QString sKey, QString sValue);
    void fnRestoreFromJsonObject(QJsonObject oJsonObject);
};

#endif // PASSWORDLISTMODEL_H
