#ifndef SETTINGSMODEL_H
#define SETTINGSMODEL_H

#include <QObject>
#include <QJsonArray>
#include <QJsonObject>
#include <QFile>
#include <QException>
#include <QDebug>
#include <QFileInfo>
#include <QJsonDocument>

class SettingsModel : public QObject
{
    Q_OBJECT

protected:
    QJsonObject* poJsonObject = nullptr;
    QString sFilePath;

public:
    explicit SettingsModel(QObject *parent = nullptr);
    ~SettingsModel();

signals:

public slots:
    void fnUpdateStringValue(QVariant sName, QVariant oValue, QVariant sDefaultValue="");
    QVariant fnGetStringValue(QVariant sName, QVariant sDefaultValue="");
    void fnUpdateIntValue(QVariant sName, QVariant oValue, QVariant sDefaultValue=0);
    QVariant fnGetIntValue(QVariant sName);
    void fnUpdateBoolValue(QVariant sName, QVariant oValue);
    QVariant fnGetBoolValue(QVariant sName);
    void fnUpdateJsonArrayValue(QVariant sName, QJsonArray oValue);
    QJsonArray fnGetJsonArrayValue(QVariant sName);
    void fnSetFilePath(QString aFilePath);
    QVariant fnGetFilePath();
    QVariant fnLoad();
    QVariant fnSave();
    bool fnFileExists();
};

#endif // SETTINGSMODEL_H
