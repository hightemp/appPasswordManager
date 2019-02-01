#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QDir>
#include <QIcon>
#include "passwordlistmodel.h"
#include "passwordlistsortfilterproxymodel.h"
#include "settingsmodel.h"
#include "clipboard.h"

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QGuiApplication app(argc, argv);

    //QPixmap oPixmap(":/images/key-icon.png");
    //QSplashScreen oSplashScreen(oPixmap);
    //oSplashScreen.show();

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

    QQmlApplicationEngine oEngine;
    qmlRegisterType<PasswordListModel>("PasswordListModel", 1, 0, "PasswordListModel");
    oEngine.load(QUrl(QStringLiteral("qrc:/main.qml")));

    qDebug() << sPasswordsFilePath;

    Clipboard oClipboard;
    oClipboard.fnSetClipboard(QGuiApplication::clipboard());

    oEngine.rootContext()->setContextProperty("oClipboard", &oClipboard);

    PasswordListModel oPasswordListModel;
    oPasswordListModel.fnSetFilePath(sPasswordsFilePath);

    PasswordListSortFilterProxyModel oPasswordListSortFilterProxyModel;
    oPasswordListSortFilterProxyModel.setSourceModel(&oPasswordListModel);

    oEngine.rootContext()->setContextProperty("oPasswordListModel", &oPasswordListModel);
    oEngine.rootContext()->setContextProperty("oPasswordListSortFilterProxyModel", &oPasswordListSortFilterProxyModel);

    SettingsModel oSettingsModel;

    oSettingsModel.fnSetFilePath(sConfigFilePath);

    oEngine.rootContext()->setContextProperty("oSettingsModel", &oSettingsModel);

    QMetaObject::invokeMethod(oEngine.rootObjects().first(), "fnStart");

    //oEngine.findChild<QObject*>("passwordsListView")->setProperty("model", &oPasswordListModel);

    //QObject *oRootObject = qobject_cast<QObject*>(oEngine.rootObjects().first());

    /*
    QObject::connect(
        oRootObject,
        SIGNAL(fnTest(QVariant)),
        &oPasswordStore,
        SLOT(fnTest(QVariant))
    );
    */
    //oSplashScreen.finish();
    return app.exec();
}
