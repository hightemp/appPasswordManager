#include "settingsmodel.h"

SettingsModel::SettingsModel(QObject *parent) : QObject(parent)
{
    this->poJsonObject = new QJsonObject();
}

SettingsModel::~SettingsModel()
{
    delete this->poJsonObject;
}

void SettingsModel::fnUpdateStringValue(QVariant sName, QVariant oValue, QVariant sDefaultValue)
{
    QString sResult = oValue.toString();
    (*this->poJsonObject)[sName.toString()] = sResult.isEmpty() ? sDefaultValue.toString() : sResult;
}

QVariant SettingsModel::fnGetStringValue(QVariant sName, QVariant sDefaultValue)
{
    QString sResult = (*this->poJsonObject)[sName.toString()].toString();
    return sResult.isEmpty() ? sDefaultValue : sResult;
}

void SettingsModel::fnUpdateBoolValue(QVariant sName, QVariant oValue)
{
    (*this->poJsonObject)[sName.toString()] = oValue.toBool();
}

QVariant SettingsModel::fnGetBoolValue(QVariant sName)
{
    return (*this->poJsonObject)[sName.toString()].toBool();
}

void SettingsModel::fnUpdateJsonArrayValue(QVariant sName, QJsonArray oValue)
{
    (*this->poJsonObject)[sName.toString()] = oValue;
}

QJsonArray SettingsModel::fnGetJsonArrayValue(QVariant sName)
{
    return (*this->poJsonObject)[sName.toString()].toArray();
}

void SettingsModel::fnSetFilePath(QString aFilePath)
{
    this->sFilePath = aFilePath;
}

QVariant SettingsModel::fnGetFilePath()
{
    return this->sFilePath;
}

QVariant SettingsModel::fnLoad()
{
    qDebug() << __PRETTY_FUNCTION__ << __FUNCTION__;
    if (this->poJsonObject != nullptr) {
        delete this->poJsonObject;
    }

    this->poJsonObject = new QJsonObject;

    if (!this->fnFileExists()) {
        return 0;
    }

    QFile oFileObj(this->sFilePath);

    if (!oFileObj.open(QIODevice::ReadOnly)) {
        return -1;
    }

    QByteArray oByteArray = oFileObj.readAll();

    qDebug() << oByteArray;

    QJsonDocument oJsonDocument = QJsonDocument::fromJson(oByteArray);

    oFileObj.close();

    if (!oJsonDocument.isObject()) {
        return -2;
    }

    *this->poJsonObject = oJsonDocument.object();

    return 1;
}

QVariant SettingsModel::fnSave()
{
    qDebug() << __FUNCTION__;

    QFile oFileObj(this->sFilePath);

    if (!oFileObj.open(QIODevice::WriteOnly)) {
        return -1;
    }

    QJsonDocument oJsonDocument(*this->poJsonObject);

    QByteArray oByteArray = oJsonDocument.toJson();

    qDebug() << oByteArray;

    oFileObj.write(oByteArray);

    oFileObj.close();

    return 1;
}

bool SettingsModel::fnFileExists()
{
    qDebug() << __FUNCTION__;
    QFileInfo oFileInfo(this->sFilePath);

    return oFileInfo.exists() && oFileInfo.isFile();
}
