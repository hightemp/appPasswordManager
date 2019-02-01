import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Qt.labs.platform 1.0
import QtQuick.Dialogs 1.2
import QtQuick.Window 2.12
import QtWebSockets 1.1
import PasswordListModel 1.0

ApplicationWindow {
    id: applicationWindow
    visible: true
    width: 640
    height: 480
    title: qsTr("Passwords")

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

    onClosing: {
        close.accepted = false
        applicationWindow.hide()
    }

    onXChanged: {
        oSettingsModel.fnUpdateStringValue("applicationWindow.x", applicationWindow.x);
        oSettingsModel.fnSave();
    }

    onYChanged: {
        oSettingsModel.fnUpdateStringValue("applicationWindow.y", applicationWindow.y);
        oSettingsModel.fnSave();
    }

    Component.onCompleted: {}

    function fnStart()
    {
        if (!oSettingsModel.fnFileExists()) {
            oSettingsModel.fnSave();
        }

        oSettingsModel.fnLoad();

        applicationWindow.setX(oSettingsModel.fnGetStringValue("applicationWindow.x"));
        applicationWindow.setY(oSettingsModel.fnGetStringValue("applicationWindow.y"));

        if (!oPasswordListModel.fnFileExists()) {
            return masterPasswordFirstRunMessageDialog.open();
        }

        masterPasswordDialog.open();
    }

    WebSocketServer {
        id: passwordSyncServer

        host: "0.0.0.0"
        listen: true
        accept: true
        port: 3002

        onClientConnected: {
            webSocket
                .onTextMessageReceived
                .connect(function(sCommand)
                {
                    if (sCommand == "SYNC_0" || sCommand == "SYNC_1") {
                        webSocket.sendBinaryMessage(oPasswordListModel.fnToByteArray());
                    }
                    if (sCommand == "SYNC_2" || sCommand == "SYNC_3") {
                        webSocket
                            .onBinaryMessageReceived
                            .connect(function(sMessage)
                            {
                                oPasswordListModel.fnFromByteArray(sMessage, {SYNC_2:0, SYNC_3:1}[sCommand]);
                                oPasswordListModel.fnSave();
                            });
                    }
                });
        }

        onErrorStringChanged: {

        }
    }

    WebSocket {
        id: passwordSyncClient
        property string sCommand: ""
        property var fnCallBack
        property var fnErrorCallBack
        property string sStatus: "Status:"

        active: false

        onBinaryMessageReceived: {
            if (sCommand == "SYNC_0" || sCommand == "SYNC_1") {
                oPasswordListModel.fnFromByteArray(message, {SYNC_0:0, SYNC_1:1}[sCommand]);
                oPasswordListModel.fnSave();
                sStatus = "Status: synchronized";
                if (fnCallBack)
                    fnCallBack();
            }
        }

        onStatusChanged: {
            if (status == WebSocket.Error) {
                sStatus = qsTr("Client error: %1").arg(errorString);
                if (fnErrorCallBack)
                    fnErrorCallBack();
            } else if (status == WebSocket.Open) {
                sStatus = "Status: connected";

                sendTextMessage(sCommand);

                if (sCommand == "SYNC_2" || sCommand == "SYNC_3") {
                    sendBinaryMessage(oPasswordListModel.fnToByteArray());
                    sStatus = "Status: synchronized";
                    if (fnCallBack)
                        fnCallBack();
                }
            } else if (status == WebSocket.Connecting) {
                sStatus = "Status: connecting..";
            }  else if (status == WebSocket.Closing) {
                //sStatus = "Status: closing connection..";
            } else if (status == WebSocket.Closed) {
                //sStatus = "Status: connection closed";
            }
        }
    }

    StackView {
        id: stackView
        initialItem: passwordsListViewPage
        anchors.fill: parent
        property var oPasswordsListViewModel
        property int iEditedRecordIndex: -2
        property string sName: ""
        property string sUser: ""
        property string sPassword: ""
        property bool settingsPageShowUserInList
        property bool settingsPageShowPasswordInList
        property string syncPageServerIP
        property string syncPageSyncMethod

        Component {
            id: passwordsListViewPage

            Rectangle {
                id: passwordsListViewRectangle
                ScrollView {
                    id: passwordsListViewScrollView
                    anchors {
                        right: parent.right
                        top: parent.top
                        left: parent.left
                        bottom: passwordsListViewPageBottomColumnLayout.top
                    }
                    ListView {
                        id: passwordsListView
                        width: parent.width
                        orientation: ListView.Vertical
                        model: stackView.oPasswordsListViewModel
                        focus: true
                        highlight: Rectangle {
                            color: "skyblue"
                        }
                        highlightFollowsCurrentItem: true
                        delegate: Item {
                            id: passwordsListDelegate

                            property var view: ListView.view
                            property bool isCurrent: ListView.isCurrentItem

                            width: view.width
                            height: 50

                            Text {
                                padding: 10

                                renderType: Text.NativeRendering
                                text: "<b>"+name+"</b>"+
                                      (oSettingsModel.fnGetBoolValue("settingsPageShowUserInList") ||
                                       oSettingsModel.fnGetBoolValue("settingsPageShowPasswordInList") ? "<br>" : "" ) +
                                      (oSettingsModel.fnGetBoolValue("settingsPageShowUserInList") ? "<b>User:</b> "+user : "") +
                                      (oSettingsModel.fnGetBoolValue("settingsPageShowPasswordInList") ? " <b>Password:</b> "+password : "")
                            }

                            MouseArea {
                                anchors.fill: parent

                                onClicked: {
                                    view.currentIndex = model.index;
                                }

                                onDoubleClicked: {
                                    view.currentIndex = model.index;
                                    stackView.sName = model.name;
                                    stackView.sUser = model.user;
                                    stackView.sPassword = model.password;
                                    stackView.iEditedRecordIndex = model.index;

                                    stackView.push(passwordEditPage);
                                }
                            }
                        }
                    }

                }

                ColumnLayout {
                    id: passwordsListViewPageBottomColumnLayout

                    anchors {
                        right: parent.right
                        bottom: parent.bottom
                        left: parent.left
                    }

                    RowLayout {
                        Layout.fillHeight: true

                        Button {
                            id: addButton
                            //Layout.minimumWidth: (parent.width-20)/4 + 1
                            text: "Add"
                            Layout.fillWidth: true

                            onClicked: {
                                stackView.iEditedRecordIndex = -1;
                                stackView.sName = "";
                                stackView.sUser = "";
                                stackView.sPassword = "";

                                stackView.push(passwordEditPage);
                            }
                        }

                        Button {
                            id: deleteButton
                            //Layout.minimumWidth: (parent.width-20)/4 + 1
                            text: "Delete"
                            Layout.fillWidth: true

                            onClicked: {
                                deleteItemDialog.open();
                            }
                        }

                    }

                    RowLayout {
                        Layout.fillHeight: true

                        Button {
                            id: syncButton
                            //Layout.minimumWidth: (parent.width-20)/4 + 1
                            text: "Synchronize"
                            Layout.fillWidth: true

                            onClicked: {
                                stackView.syncPageServerIP = oSettingsModel.fnGetStringValue("syncPageServerIP");
                                stackView.syncPageSyncMethod = oSettingsModel.fnGetStringValue("syncPageSyncMethod");
                                stackView.push(syncPage);
                            }
                        }

                        Button {
                            id: settingsButton
                            //Layout.minimumWidth: (parent.width-20)/4 + 1
                            text: "Settings"
                            Layout.fillWidth: true

                            onClicked: {
                                stackView.settingsPageShowUserInList = oSettingsModel.fnGetBoolValue("settingsPageShowUserInList")
                                stackView.settingsPageShowPasswordInList = oSettingsModel.fnGetBoolValue("settingsPageShowPasswordInList")
                                stackView.push(settingsPage);
                            }
                        }
                    }
                }

            }
        }

        Component {
            id: passwordEditPage

            Rectangle {
                ScrollView {
                    id: passwordEditPageScrollView
                    anchors {
                        right: parent.right
                        top: parent.top
                        left: parent.left
                        bottom: passwordEditPageBottomRowLayout.top
                    }

                    ColumnLayout {
                        spacing: 2
                        anchors.fill: parent
                        anchors.margins: 10

                        Label {
                            text: "Name"
                        }

                        RowLayout {
                            spacing: 2

                            TextField {
                                id: nameTextField
                                Layout.minimumWidth: passwordEditPageScrollView.width-passwordEditPageCopyNameButton.width-20
                                text: stackView.sName
                                selectByMouse: true
                            }

                            Button {
                                id: passwordEditPageCopyNameButton
                                text: "Copy"
                                onClicked: {
                                    oClipboard.fnCopy(nameTextField.text);
                                }
                            }
                        }

                        Label {
                            text: "User"
                        }

                        RowLayout {
                            spacing: 2

                            TextField {
                                id: userTextField
                                Layout.minimumWidth: passwordEditPageScrollView.width-passwordEditPageCopyUserButton.width-20
                                text: stackView.sUser
                                selectByMouse: true
                            }

                            Button {
                                id: passwordEditPageCopyUserButton
                                text: "Copy"
                                onClicked: {
                                    oClipboard.fnCopy(userTextField.text);
                                }
                            }
                        }

                        Label {
                            text: "Password"
                        }

                        RowLayout {
                            spacing: 2

                            TextField {
                                id: passwordTextField
                                Layout.minimumWidth: passwordEditPageScrollView.width-passwordEditPageCopyPasswordButton.width-20
                                text: stackView.sPassword
                                selectByMouse: true
                            }

                            Button {
                                id: passwordEditPageCopyPasswordButton
                                text: "Copy"
                                onClicked: {
                                    oClipboard.fnCopy(passwordTextField.text);
                                }
                            }
                        }
                    }
                }

                RowLayout {
                    id: passwordEditPageBottomRowLayout

                    anchors {
                        right: parent.right
                        bottom: parent.bottom
                        left: parent.left
                    }

                    Button {
                        id: passwordEditPageBackButton

                        Layout.minimumWidth: parent.width/2
                        text: "Back"
                        onClicked: {
                            stackView.pop();
                        }
                    }

                    Button {
                        id: passwordEditPageSaveButton

                        Layout.minimumWidth: parent.width/2
                        text: "Save"
                        onClicked: {
                            if (stackView.iEditedRecordIndex == -1) {
                                stackView.iEditedRecordIndex = oPasswordListModel.fnAddRow();
                            }

                            if (stackView.iEditedRecordIndex > -1) {
                                var oIndex = oPasswordListModel.index(stackView.iEditedRecordIndex, 0);
                                oPasswordListModel.setData(oIndex, nameTextField.text, PasswordListModel.NameRole);
                                oPasswordListModel.setData(oIndex, userTextField.text, PasswordListModel.UserRole);
                                oPasswordListModel.setData(oIndex, passwordTextField.text, PasswordListModel.PasswordRole);
                            }

                            stackView.pop();
                        }
                    }
                }
            }
        }

        Component {
            id: settingsPage

            Rectangle {
                ScrollView {
                    id: settingsPageScrollView
                    anchors {
                        right: parent.right
                        top: parent.top
                        left: parent.left
                        bottom: settingsPageBottomRowLayout.top
                    }

                    ColumnLayout {
                        spacing: 2
                        anchors.fill: parent
                        anchors.margins: 10

                        CheckBox {
                            id: settingsPageShowUserInList
                            text: "Show user in list"
                            checked: stackView.settingsPageShowUserInList
                        }
                        CheckBox {
                            id: settingsPageShowPasswordsInList
                            text: "Show passwords in list"
                            checked: stackView.settingsPageShowPasswordInList
                        }
                    }
                }

                RowLayout {
                    id: settingsPageBottomRowLayout

                    anchors {
                        right: parent.right
                        bottom: parent.bottom
                        left: parent.left
                    }

                    Button {
                        id: settingsPageBackButton

                        Layout.fillWidth: true
                        text: "Back"
                        onClicked: {
                            stackView.pop();
                        }
                    }

                    Button {
                        id: settingsPageSaveButton

                        Layout.fillWidth: true
                        text: "Save"
                        onClicked: {
                            oSettingsModel.fnUpdateBoolValue("settingsPageShowUserInList", settingsPageShowUserInList.checked);
                            oSettingsModel.fnUpdateBoolValue("settingsPageShowPasswordInList", settingsPageShowPasswordsInList.checked);
                            oPasswordListModel.fnUpdate();
                            oSettingsModel.fnSave();
                            stackView.pop();
                        }
                    }
                }
            }
        }

        Component {
            id: syncPage

            Rectangle {
                ScrollView {
                    id: syncPageScrollView
                    anchors {
                        right: parent.right
                        top: parent.top
                        left: parent.left
                        bottom: syncPageBottomRowLayout.top
                    }

                    BusyIndicator {
                        id: syncPageBusyIndicator
                        anchors.centerIn: parent
                        visible: false
                        running: true
                    }

                    ColumnLayout {
                        spacing: 2
                        anchors.fill: parent

                        anchors.margins: 10

                        Label {
                            text: "Server IP"
                        }
                        TextField {
                            id: syncPageServerIPTextField
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignJustify

                            focus: true
                            text: stackView.syncPageServerIP
                            selectByMouse: true

                            onEditingFinished: {
                                oSettingsModel.fnUpdateStringValue("syncPageServerIP", syncPageServerIPTextField.text);
                                oSettingsModel.fnSave();
                            }
                        }
                        Label {
                            text: "Synchronization method"
                        }
                        ComboBox {
                            id: syncPageSyncMethodComboBox
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignJustify

                            model: [
                                "Download and replace",
                                "Download and merge",
                                "Upload and replace",
                                "Upload and merge"
                            ]

                            currentIndex: stackView.syncPageSyncMethod

                            onCurrentIndexChanged: {
                                oSettingsModel.fnUpdateStringValue("syncPageSyncMethod", syncPageSyncMethodComboBox.currentIndex);
                                oSettingsModel.fnSave();
                            }
                        }

                        Label {
                            id: syncPageStatusLabel
                            padding: 10

                            text: passwordSyncClient.sStatus
                        }

                        Item { Layout.fillHeight: true }
                    }
                }

                RowLayout {
                    id: syncPageBottomRowLayout

                    anchors {
                        right: parent.right
                        bottom: parent.bottom
                        left: parent.left
                    }

                    Button {
                        id: syncPageBackButton

                        Layout.fillWidth: true
                        text: "Back"
                        onClicked: {
                            stackView.pop();
                        }
                    }

                    Button {
                        id: syncPageSaveButton

                        Layout.fillWidth: true
                        text: "Sync"
                        onClicked: {
                            syncPageBackButton.enabled = false;
                            syncPageSaveButton.enabled = false;
                            syncPageServerIPTextField.enabled = false;
                            syncPageSyncMethodComboBox.enabled = false
                            syncPageBusyIndicator.visible = true;

                            passwordSyncClient.sCommand = "SYNC_"+oSettingsModel.fnGetStringValue("syncPageSyncMethod");
                            passwordSyncClient.fnCallBack = this.settingsPageSaveButtonCallBack;
                            passwordSyncClient.fnErrorCallBack = this.settingsPageSaveButtonErrorCallBack;
                            passwordSyncClient.url = "ws://"+syncPageServerIPTextField.text+":3002";
                            passwordSyncClient.active = true;
                        }

                        function settingsPageSaveButtonErrorCallBack()
                        {
                            settingsPageSaveButtonCallBack();
                        }

                        function settingsPageSaveButtonCallBack()
                        {
                            syncPageBusyIndicator.visible = false;
                            syncPageBackButton.enabled = true;
                            syncPageSaveButton.enabled = true;
                            syncPageServerIPTextField.enabled = true;
                            syncPageSyncMethodComboBox.enabled = true
                            passwordSyncClient.active = false;
                        }
                    }
                }
            }
        }
    }

    MessageDialog {
        id: deleteItemDialog
        title: qsTr("Delete item?")
        standardButtons: Dialog.No | Dialog.Yes
        text: "Delete item?"

        onYes: {
            oPasswordListModel.fnRemoveRow(stackView.iEditedRecordIndex);
        }
    }

    MessageDialog {
        id: masterPasswordErrorDialog
        title: "Error"
        text: ""

        property bool bShowPasswordDialog: false

        onAccepted: {
            if (bShowPasswordDialog) {
                masterPasswordDialog.open();
            }
        }
    }

    MessageDialog {
        id: masterPasswordMessageDialog
        title: "Password must be 8 symbols length minimum"
        text: "Password must be 8 symbols length minimum"

        onAccepted: {
            masterPasswordDialog.open();
        }
    }

    MessageDialog {
        id: masterPasswordFirstRunMessageDialog
        title: "First run"
        text: "This is the first launch. Set the master-password to be encrypted file with passwords"

        onAccepted: {
            masterPasswordDialog.open();
        }
    }

    Dialog {
        id: masterPasswordDialog
        title: qsTr("Master-password")

        standardButtons: Dialog.Cancel | Dialog.Ok

        onVisibleChanged: {
            if (!this.visible) {
                //masterPasswordDialog.visible = true;
                //return masterPasswordDialog.open();
            } else {
                masterPasswordField.text = "";
                masterPasswordField.focus = masterPasswordDialog.visible;
            }
        }

        //onDestroyed: {
        //    console.log("onDiscard");
        //}

        onRejected: {
            Qt.quit();
        }

        onAccepted: {
            Qt.inputMethod.hide();

            if (masterPasswordField.text.length<8) {
                return masterPasswordMessageDialog.open();
            }

            oPasswordListModel.fnSetPassword(masterPasswordField.text);
            var iLoadResult = oPasswordListModel.fnLoad();

            if (iLoadResult == 0) {
                var iSaveResult = oPasswordListModel.fnSave();
            }

            if (iLoadResult < 0 || iSaveResult<0) {
                masterPasswordErrorDialog.bShowPasswordDialog = false;
                if (iSaveResult == -1) {
                    masterPasswordErrorDialog.text = "Can't open file %1 for writing".arg(oPasswordListModel.fnGetFilePath());
                }
                if (iSaveResult == -10) {
                    masterPasswordErrorDialog.text = "Key is empty";
                }
                if (iSaveResult == -20) {
                    masterPasswordErrorDialog.text = "Encrypted string is empty";
                }
                if (iLoadResult == -1) {
                    masterPasswordErrorDialog.text = "Can't open file %1 for reading".arg(oPasswordListModel.fnGetFilePath());
                }
                if (iLoadResult == -2) {
                    masterPasswordErrorDialog.text = "Wrong json format in %1".arg(oPasswordListModel.fnGetFilePath());
                }
                if (iLoadResult == -10) {
                    masterPasswordErrorDialog.text = "Key is empty";
                }
                if (iLoadResult == -20) {
                    masterPasswordErrorDialog.text = "Encrypted string is empty";
                }
                if (iLoadResult == -30) {
                    masterPasswordErrorDialog.text = "Can't decrypt passwords file. Master-password is wrong.";
                    masterPasswordErrorDialog.bShowPasswordDialog = true;
                }
                masterPasswordErrorDialog.open();
            }

            stackView.oPasswordsListViewModel = oPasswordListSortFilterProxyModel;
        }

        TextField {
            id: masterPasswordField
            focus: true
            selectByMouse: true
            anchors.fill: parent
            Layout.alignment: Qt.AlignBaseline
            Layout.fillWidth: true
            text: ""
            echoMode: TextInput.Password

            Keys.onEnterPressed: {
                Qt.inputMethod.hide();
            }
            Keys.onReturnPressed: {
                Qt.inputMethod.hide();
            }
        }

        Component.onCompleted: {
            masterPasswordField.focus = true;
        }
   }
}
