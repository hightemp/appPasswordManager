#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QDir>
#include <QIcon>
#include <QQuickView>
#include "passwordlistmodel.h"
#include "passwordlistsortfilterproxymodel.h"
#include "settingsmodel.h"
#include "clipboard.h"
#include "styler.h"
#include <QPalette>

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QGuiApplication app(argc, argv);

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

    Styler oStyler;

    qDebug() << oSettingsModel.fnGetStringValue("settingsPageStyle");

    oStyler.fnSetStyle(oSettingsModel.fnGetStringValue("settingsPageStyle").toInt());

    PasswordListModel oPasswordListModel;
    oPasswordListModel.fnSetFilePath(sPasswordsFilePath);

    PasswordListSortFilterProxyModel oPasswordListSortFilterProxyModel;
    oPasswordListSortFilterProxyModel.setSourceModel(&oPasswordListModel);

    Clipboard oClipboard;
    oClipboard.fnSetClipboard(QGuiApplication::clipboard());

    QQuickView oView;
    oView.setSource(QUrl(QStringLiteral("qrc:/main.qml")));
    oView.setResizeMode(QQuickView::SizeRootObjectToView);
    oView.setGeometry(QRect(0, 0, 640, 480));
    QObject::connect(oView.engine(), SIGNAL(quit()), qApp, SLOT(quit()));
    oView.setTitle("Passwords manager");
    //oView.setColor();

    qDebug() << sPasswordsFilePath;

    oView.rootContext()->setContextProperty("oClipboard", &oClipboard);

    oView.rootContext()->setContextProperty("oPasswordListModel", &oPasswordListModel);
    oView.rootContext()->setContextProperty("oPasswordListSortFilterProxyModel", &oPasswordListSortFilterProxyModel);

    oView.rootContext()->setContextProperty("oSettingsModel", &oSettingsModel);
    oView.rootContext()->setContextProperty("oWindow", &oView);

    oView.rootContext()->setContextProperty("oStyler", &oStyler);

    oView.show();

    QObject* oRootObject = (QObject*) oView.rootObject();
    QMetaObject::invokeMethod(oRootObject, "fnStart");

    return app.exec();
}
