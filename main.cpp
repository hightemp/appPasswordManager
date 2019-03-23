#ifndef QTQUICKCONTROLSAPPLICATION_H
#define QTQUICKCONTROLSAPPLICATION_H

    #ifdef QT_WIDGETS_LIB
        #include <QtWidgets/QApplication>
    #else
        #include <QtGui/QGuiApplication>
    #endif

    QT_BEGIN_NAMESPACE

    #ifdef QT_WIDGETS_LIB
        #define QtQuickControlsApplication QApplication
    #else
        #define QtQuickControlsApplication QGuiApplication
    #endif

    QT_END_NAMESPACE

#endif

#include <QtQml/QQmlApplicationEngine>
#include <QtGui/QSurfaceFormat>
#include <QtQuick/QQuickWindow>
#include <QQmlContext>

#include <QDir>
#include <QIcon>
#include <QQuickView>
#include <QStandardPaths>
#include "PasswordListModel.h"
#include "PasswordListSortFilterProxyModel.h"
#include "SettingsModel.h"
#include "Clipboard.h"
#include "Styler.h"
#include "ServersListModel.h"

#define QT_NO_DEBUG_OUTPUT

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QtQuickControlsApplication app(argc, argv);

    app.setWindowIcon(QIcon(":/images/key-icon.png"));

    QString sConfigFilePath;
    QString sPasswordsFilePath;
    QString sConfigFileName = ".appPasswordManager.cfg";
    QString sPasswordsFileName = ".appPasswordManager.pwd";

    if (QSysInfo::kernelType()=="winnt") {
        sConfigFilePath = QDir::homePath() + "\\" + sConfigFileName;
        sPasswordsFilePath = QDir::homePath() + "\\" + sPasswordsFileName;
    } else if (QSysInfo::kernelType()=="darwin") {
        sConfigFilePath = QDir::homePath() + "/" + sConfigFileName;
        sPasswordsFilePath = QDir::homePath() + "/" + sPasswordsFileName;
    } else if (QSysInfo::kernelType()=="linux") {
        sConfigFilePath = QDir::homePath() + "/" + sConfigFileName;
        sPasswordsFilePath = QDir::homePath() + "/" + sPasswordsFileName;
    }

    qmlRegisterType<PasswordListModel>("PasswordListModel", 1, 0, "PasswordListModel");

    SettingsModel oSettingsModel;
    oSettingsModel.fnSetFilePath(sConfigFilePath);

    if (!oSettingsModel.fnFileExists()) {
        oSettingsModel.fnSave();
    }

    oSettingsModel.fnLoad();

    ServersListModel oServersListModel(&oSettingsModel);

    //Styler oStyler;

    //qDebug() << oSettingsModel.fnGetStringValue("settingsPageStyle");

    //oStyler.fnSetStyle(oSettingsModel.fnGetStringValue("settingsPageStyle").toInt());

    PasswordListModel oPasswordListModel;
    oPasswordListModel.fnSetFilePath(sPasswordsFilePath);

    PasswordListSortFilterProxyModel oPasswordListSortFilterProxyModel;
    oPasswordListSortFilterProxyModel.setSourceModel(&oPasswordListModel);

    Clipboard oClipboard;
    oClipboard.fnSetClipboard(QGuiApplication::clipboard());


    QQmlApplicationEngine oEngine(QUrl("qrc:/main.qml"));

    qDebug() << sPasswordsFilePath;

    oEngine.rootContext()->setContextProperty("oClipboard", &oClipboard);

    oEngine.rootContext()->setContextProperty("oPasswordListModel", &oPasswordListModel);
    oEngine.rootContext()->setContextProperty("oPasswordListSortFilterProxyModel", &oPasswordListSortFilterProxyModel);

    oEngine.rootContext()->setContextProperty("oSettingsModel", &oSettingsModel);
    oEngine.rootContext()->setContextProperty("oServersListModel", &oServersListModel);
    oEngine.rootContext()->setContextProperty("oWindow", &oEngine);

    //oEngine.rootContext()->setContextProperty("oStyler", &oStyler);

    #ifdef Q_OS_ANDROID
        oEngine.rootContext()->setContextProperty("sOSType", "Mobile");
    #else
        #ifdef Q_OS_IOS
            oEngine.rootContext()->setContextProperty("sOSType", "Mobile");
        #else
            oEngine.rootContext()->setContextProperty("sOSType", "Desktop");
        #endif
    #endif

    QMetaObject::invokeMethod(oEngine.rootObjects()[0], "fnStart");


    return app.exec();
}
