#include "FilesListModel.h"

FilesListModel::FilesListModel(QObject *poParent) : QAbstractListModel (poParent)
{
    this->oCurrentPath = QDir(QDir::homePath());
    this->oFileInfoList = this->oCurrentPath.entryInfoList(QDir::NoDotAndDotDot);
}

FilesListModel::~FilesListModel()
{

}

QHash<int, QByteArray> FilesListModel::roleNames() const
{
    qDebug() << __FUNCTION__;

    return {
        { FileNameRole, "fileName" },
        { IsDir, "isDir" }
    };
}

QVariant FilesListModel::data(const QModelIndex &oIndex, int iRole) const
{
    qDebug() << __FUNCTION__;

    if (!oIndex.isValid())
        return QVariant();

    if (oIndex.row() >= this->oFileInfoList.size())
        return QVariant();

    if (iRole == FileNameRole) {
        return this->oFileInfoList[oIndex.row()].fileName();
    } if (iRole == IsDir) {
        return this->oFileInfoList[oIndex.row()].isDir();
    } else
        return QVariant();
}

bool FilesListModel::setData(const QModelIndex &oIndex, const QVariant &oValue, int iRole)
{
    qDebug() << __FUNCTION__;

    return false;
}

QVariant FilesListModel::headerData(int iSection, Qt::Orientation oOrientation, int iRole) const
{
    qDebug() << __FUNCTION__;

    if (iRole != Qt::DisplayRole)
         return QVariant();

     if (oOrientation == Qt::Horizontal)
         return QString("Column %1").arg(iSection);
     else
         return QString("Row %1").arg(iSection);
}

Qt::ItemFlags FilesListModel::flags(const QModelIndex &oIndex) const
{
    qDebug() << __FUNCTION__;

    if (!oIndex.isValid())
        return Qt::ItemIsEnabled;

    return QAbstractItemModel::flags(oIndex) | Qt::ItemIsEditable;
}

bool FilesListModel::insertRows(int iPosition, int iRows, const QModelIndex &oParent)
{
    qDebug() << __FUNCTION__;

    return false;
}

bool FilesListModel::removeRows(int iPosition, int iRows, const QModelIndex &oParent)
{
    qDebug() << __FUNCTION__;

    if (iRows==0) {
        return true;
    }

    beginRemoveRows(QModelIndex(), iPosition, iPosition+iRows-1);

    endRemoveRows();

    return true;
}

QModelIndex FilesListModel::index(int iRow, int iColumn, const QModelIndex &oParent) const
{
    qDebug() << __FUNCTION__;

    return createIndex(iRow, iColumn);
}

QModelIndex FilesListModel::parent(const QModelIndex &oChild) const
{
    qDebug() << __FUNCTION__;

    return QModelIndex();
}

int FilesListModel::rowCount(const QModelIndex &oParent) const
{
    int iRows = this->oCurrentPath.count();

    qDebug() << __FUNCTION__ << iRows;

    return iRows;
}

int FilesListModel::columnCount(const QModelIndex &oParent) const
{
    qDebug() << __FUNCTION__;

    Q_UNUSED(oParent);

    return 1;
}

bool FilesListModel::hasChildren(const QModelIndex &oParent) const
{
    qDebug() << __FUNCTION__;

    return false;
}

void FilesListModel::fnOpenDir(int iIndex)
{
    qDebug() << __FUNCTION__;

    //this->oFileInfoList = this->oCurrentPath.entryInfoList();
    if (iIndex<0 || iIndex>=this->oFileInfoList.size()) {
        qDebug() << "iIndex " << iIndex << " out of bounds";
        return;
    }

    beginResetModel();

    this->fnSetPath(this->oFileInfoList[iIndex].fileName());

    endResetModel();
    /*
    for (int i = 0; i < list.size(); ++i) {
        QFileInfo fileInfo = list.at(i);
        std::cout << qPrintable(QString("%1 %2").arg(fileInfo.size(), 10)
                                                .arg(fileInfo.fileName()));
        std::cout << std::endl;
    }
    */
}

void FilesListModel::fnSetPath(QString sPath)
{
    qDebug() << __FUNCTION__;

    this->oCurrentPath.setPath(sPath);
    this->oFileInfoList = this->oCurrentPath.entryInfoList(QDir::NoDotAndDotDot);
}

QString FilesListModel::fnGetCurrentPath()
{
    qDebug() << __FUNCTION__;

    return this->oCurrentPath.path();
}

void FilesListModel::fnUp()
{
    qDebug() << __FUNCTION__;

    this->oCurrentPath.cdUp();
}
