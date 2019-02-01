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
    void fnUpdateStringValue(QVariant sName, QVariant oValue);
    QVariant fnGetStringValue(QVariant sName);
    void fnUpdateBoolValue(QVariant sName, QVariant oValue);
    QVariant fnGetBoolValue(QVariant sName);
    void fnSetFilePath(QString aFilePath);
    QVariant fnGetFilePath();
    QVariant fnLoad();
    QVariant fnSave();
    bool fnFileExists();
};

#endif // SETTINGSMODEL_H
