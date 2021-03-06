import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Qt.labs.platform 1.0
import QtQuick.Dialogs 1.2
import QtQuick.Window 2.0
import QtWebSockets 1.1
import PasswordListModel 1.0

ApplicationWindow {
    id: applicationWindow
    visible: false
    title: "Passwords manager"
    //anchors.fill: parent

    SystemTrayIcon {
        visible: true
        iconSource: "qrc:/images/key-icon.png"

        menu: Menu {
            MenuItem {
                text: qsTr("Quit")
                onTriggered: Qt.quit()
            }
        }

        onActivated: {
            if(reason !== SystemTrayIcon.Context) {
                applicationWindow.show()
                applicationWindow.raise()
                applicationWindow.requestActivate()
            }
        }
    }

    Connections {
        target: applicationWindow
        onClosing: {
            console.log('onClosing');
            if (sOSType != "Mobile") {
                applicationWindow.hide();
                close.accepted = false
                console.log('onClosing', close.accepted);
            }
        }
        onVisibilityChanged: {
           console.log("onVisibilityChanged", applicationWindow.visibility, applicationWindow.visible);
        }
    }

    onXChanged: {
        oSettingsModel.fnUpdateStringValue("applicationWindow.x", applicationWindow.x);
        oSettingsModel.fnSave();
    }

    onYChanged: {
        oSettingsModel.fnUpdateStringValue("applicationWindow.y", applicationWindow.y);
        oSettingsModel.fnSave();
    }

    function fnStart()
    {
        console.log('fnStart');

        stackView.oExportFilesListModel = oExportFilesListModel;
        stackView.oImportFilesListModel = oImportFilesListModel;

        applicationWindow.visible = sOSType == "Mobile";

        if (sOSType != "Mobile") {
            applicationWindow.setWidth(640);
            applicationWindow.setHeight(480);
        }
        console.log('Set window position: ', oSettingsModel.fnGetStringValue("applicationWindow.x"), oSettingsModel.fnGetStringValue("applicationWindow.y"));
        applicationWindow.setX(oSettingsModel.fnGetStringValue("applicationWindow.x"));
        applicationWindow.setY(oSettingsModel.fnGetStringValue("applicationWindow.y"));

        if (!oPasswordListModel.fnFileExists()) {
            stackView.masterPasswordEnterPageStatusLabelText = "File with passwords not found.<br> Will be created new.";
        }
    }

    PasswordSyncServer { id: passwordSyncServer }

    Timer {
        id: connectionTimeout;

        repeat: false;
        interval: 1000;

        onTriggered: {
            connectionTimeout.stop();

            passwordSyncClient.sStatus = "Error";
            if (passwordSyncClient.fnErrorCallBack)
                passwordSyncClient.fnErrorCallBack("Client error: "+passwordSyncClient.sHost+":"+passwordSyncClient.sPort+" - connection timeout");
        }
    }

    PasswordSyncClient { id: passwordSyncClient }

    Keys.onReleased: {
        console.log("Keys.onReleased", event.key);
        if (event.key == Qt.Key_Back) {
            console.log("Back button captured - wunderbar !")
            event.accepted = true
            quit();
        }
    }

    StackView {
        id: stackView
        initialItem: masterPasswordEnterPage
        anchors.fill: parent

        property var oExportFilesListModel
        property var oImportFilesListModel

        property var oPasswordsListViewModel
        property var oServersListViewModel
        property var oPasswordsChangeHistoryListViewModel

        property int iHistroyRecordIndex

        property int iEditedRecordIndex
        property bool bPasswordsListIsNewItem: false
        property string sName: ""
        property string sUser: ""
        property string sPassword: ""
        property string sAdditional: ""

        property bool settingsPageSynchronizeOnUpdate
        property bool settingsPageShowIdInList
        property bool settingsPageShowUserInList
        property bool settingsPageShowPasswordInList
        property bool settingsPageShowCreatedAtInList
        property bool settingsPageShowUpdatedAtInList
        property var settingsPageStyleModel
        property int settingsPageStyleCurrentIndex
        property string settingsPageServerHostText
        property string settingsPageServerPortText
        property string settingsPageServerStatusLabelText

        property string syncPageServerIP
        property string syncPageSyncMethod

        property string changePasswordPageOldPasswordText: ""
        property string changePasswordPageNewPasswordText: ""

        property string masterPasswordEnterPageStatusLabelText: ""

        focus: true

        onCurrentItemChanged: {
            if (currentItem && currentItem.defaultFocusItem) {
                currentItem.defaultFocusItem.focus = true
            }
        }

        MasterPasswordEnterPage { id: masterPasswordEnterPage }

        PasswordsListViewPage { id: passwordsListViewPage }

        ExportPage { id: exportPage }

        ImportPage { id: importPage }

        PasswordsChangeHistoryPage { id: passwordsChangeHistoryPage }

        PasswordEditPage { id: passwordEditPage }

        SettingsPage { id: settingsPage }

        SyncPage { id: syncPage }

        ServersListViewPage { id: serversListViewPage }

        ChangePasswordPage { id: changePasswordPage }
    }
}
