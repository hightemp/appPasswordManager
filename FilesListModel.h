#ifndef FILESLISTMODEL_H
#define FILESLISTMODEL_H

#include <QAbstractItemModel>
#include <QException>
#include <QDebug>
#include <QDir>

class FilesListModel : public QAbstractListModel
{
    Q_OBJECT
    Q_ENUMS(FilesListModelRoles)

public:
    QDir oCurrentPath;
    QFileInfoList oFileInfoList;

public:

    enum FilesListModelRoles {
        FileNameRole = Qt::UserRole + 1,
        IsDir
    };

    explicit FilesListModel(QObject *poParent = nullptr);
    ~FilesListModel() override;

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
    void fnOpenDir(int iIndex);
    void fnSetPath(QString sPath);
    QString fnGetCurrentPath();
    void fnUp();
    void fnUpdate();

};

#endif // FILESLISTMODEL_H
