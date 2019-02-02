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

    QQuickView oView;
    oView.setSource(QUrl(QStringLiteral("qrc:/main.qml")));
    oView.setResizeMode(QQuickView::SizeRootObjectToView);
    oView.setGeometry(QRect(0, 0, 640, 480));
    QObject::connect(oView.engine(), SIGNAL(quit()), qApp, SLOT(quit()));
    oView.setTitle("Passwords manager");
    //oView.

    qDebug() << sPasswordsFilePath;

    Clipboard oClipboard;
    oClipboard.fnSetClipboard(QGuiApplication::clipboard());

    oView.rootContext()->setContextProperty("oClipboard", &oClipboard);

    PasswordListModel oPasswordListModel;
    oPasswordListModel.fnSetFilePath(sPasswordsFilePath);

    PasswordListSortFilterProxyModel oPasswordListSortFilterProxyModel;
    oPasswordListSortFilterProxyModel.setSourceModel(&oPasswordListModel);

    oView.rootContext()->setContextProperty("oPasswordListModel", &oPasswordListModel);
    oView.rootContext()->setContextProperty("oPasswordListSortFilterProxyModel", &oPasswordListSortFilterProxyModel);

    SettingsModel oSettingsModel;

    oSettingsModel.fnSetFilePath(sConfigFilePath);

    oView.rootContext()->setContextProperty("oSettingsModel", &oSettingsModel);
    oView.rootContext()->setContextProperty("oWindow", &oView);

    oView.show();

    QObject* oRootObject = (QObject*) oView.rootObject();
    QMetaObject::invokeMethod(oRootObject, "fnStart");

    return app.exec();
}
