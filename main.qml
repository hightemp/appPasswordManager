import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import Qt.labs.platform 1.0
import QtQuick.Dialogs 1.2
import QtQuick.Window 2.0
import QtWebSockets 1.1
import PasswordListModel 1.0

Item {
    id: applicationWindowRootObject
    visible: true
    anchors.fill: parent

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
                oWindow.show()
                oWindow.raise()
                oWindow.requestActivate()
            }
        }
    }

    Connections {
        target: oWindow
        onClosing: {
            oWindow.hide();
            close.accepted = false
        }
        onVisibilityChanged: {
           console.log("onVisibilityChanged", oWindow.visibility, oWindow.visible);
        }
    }

    onXChanged: {
        oSettingsModel.fnUpdateStringValue("applicationWindow.x", oWindow.x);
        oSettingsModel.fnSave();
    }

    onYChanged: {
        oSettingsModel.fnUpdateStringValue("applicationWindow.y", oWindow.y);
        oSettingsModel.fnSave();
    }

    //Component.onCompleted: {}

    function fnStart()
    {
        if (!oSettingsModel.fnFileExists()) {
            oSettingsModel.fnSave();
        }

        oSettingsModel.fnLoad();

        oWindow.setX(oSettingsModel.fnGetStringValue("applicationWindow.x"));
        oWindow.setY(oSettingsModel.fnGetStringValue("applicationWindow.y"));

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
                    if (sCommand == "SYNC_0" || sCommand == "SYNC_1" || sCommand == "SYNC_2") {
                        webSocket.sendBinaryMessage(oPasswordListModel.fnToByteArray());
                    }
                    if (sCommand == "SYNC_3" || sCommand == "SYNC_4" || sCommand == "SYNC_5") {
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
            if (sCommand == "SYNC_0" || sCommand == "SYNC_1" || sCommand == "SYNC_2") {
                console.log(message);
                var iResult = oPasswordListModel.fnFromByteArray(message, {SYNC_0:0, SYNC_1:1, SYNC_2:2}[sCommand]);
                if (iResult == -3) {
                    sStatus = "Status: wrong password";
                }
                if (iResult == -2 || iResult == -1) {
                    sStatus = "Status: empty key or string";
                }
                if (iResult == 1) {
                    oPasswordListModel.fnSave();
                    sStatus = "Status: synchronized";
                }
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

                if (sCommand == "SYNC_3" || sCommand == "SYNC_4" || sCommand == "SYNC_5") {
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

    Keys.onReleased: {
        if (event.key == Qt.Key_Back) {
            console.log("Back button captured - wunderbar !")
            event.accepted = true
            Qt.quit();
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
        property string sAdditional: ""
        property bool settingsPageShowUserInList
        property bool settingsPageShowPasswordInList
        property string syncPageServerIP
        property string syncPageSyncMethod
        property string changePasswordPageOldPasswordText: ""
        property string changePasswordPageNewPasswordText: ""

        Component {
            id: passwordsListViewPage

            Item {
                id: passwordsListViewRectangle
                //color: "transparent"
                anchors.fill: parent

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
                                    stackView.sAdditional = model.additional;
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
                            //Layout.minimumWidth: (parent.width-20)/2 + 1
                            text: "Add"
                            Layout.fillWidth: true

                            onClicked: {
                                stackView.iEditedRecordIndex = -1;
                                stackView.sName = "";
                                stackView.sUser = "";
                                stackView.sPassword = "";
                                stackView.sAdditional = "";

                                stackView.push(passwordEditPage);
                            }
                        }

                        Button {
                            id: deleteButton
                            //Layout.minimumWidth: (parent.width-20)/2 + 1
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
                            //Layout.minimumWidth: (parent.width-20)/2 + 1
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
                            //Layout.minimumWidth: (parent.width-20)/2 + 1
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

            Item {
                id: passwordEditPageRectangle
                //color: "transparent"
                //visible: false

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
                                Layout.minimumWidth: passwordEditPageScrollView.width-passwordEditPageCopyNameButton.width-25
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
                                Layout.minimumWidth: passwordEditPageScrollView.width-passwordEditPageCopyUserButton.width-25
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
                                Layout.minimumWidth: passwordEditPageScrollView.width-passwordEditPageCopyPasswordButton.width-25
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

                        Label {
                            text: "Additional"
                        }

                        RowLayout {
                            spacing: 2
                            Layout.fillHeight: true;

                            Rectangle {
                                border.width: 1
                                border.color: "gray"
                                Layout.minimumWidth: passwordEditPageScrollView.width-passwordEditPageCopyAdditionalButton.width-25
                                Layout.minimumHeight: 200;

                                ScrollView {
                                    anchors.fill: parent

                                    TextArea {
                                        id: additionalTextArea
                                        text: stackView.sAdditional
                                        selectByMouse: true
                                    }
                                }
                            }

                            Button {
                                id: passwordEditPageCopyAdditionalButton
                                text: "Copy"
                                onClicked: {
                                    oClipboard.fnCopy(additionalTextArea.text);
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
                                oPasswordListModel.setData(oIndex, additionalTextArea.text, PasswordListModel.AdditionalRole);
                            }

                            stackView.pop();
                        }
                    }
                }
            }
        }

        Component {
            id: settingsPage

            Item {
                id: settingsPageRectangle
                //color: "transparent"
                //visible: false

                ScrollView {
                    id: settingsPageScrollView
                    anchors {
                        right: parent.right
                        top: parent.top
                        left: parent.left
                        bottom: settingsPageBottomColumnLayout.top
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

                ColumnLayout {
                    id: settingsPageBottomColumnLayout

                    anchors {
                        right: parent.right
                        bottom: parent.bottom
                        left: parent.left
                    }

                    RowLayout {
                        Button {
                            id: settingsPageChangePasswordButton

                            Layout.fillWidth: true
                            text: "Change master-password"
                            onClicked: {
                                stackView.changePasswordPageOldPasswordText = "";
                                stackView.changePasswordPageNewPasswordText = "";
                                stackView.push(changePasswordPage);
                            }
                        }
                    }

                    RowLayout {
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
        }

        Component {
            id: syncPage

            Item {
                id: syncPageRectangle
                //color: "transparent"
                //visible: false

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
                                "Download and add new",
                                "Upload and replace",
                                "Upload and merge",
                                "Upload and add new"
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
                        id: syncPageSyncButton

                        Layout.fillWidth: true
                        text: "Sync"
                        onClicked: {
                            syncPageBackButton.enabled = false;
                            syncPageSyncButton.enabled = false;
                            syncPageServerIPTextField.enabled = false;
                            syncPageSyncMethodComboBox.enabled = false
                            syncPageBusyIndicator.visible = true;

                            passwordSyncClient.sCommand = "SYNC_"+oSettingsModel.fnGetStringValue("syncPageSyncMethod");
                            passwordSyncClient.fnCallBack = this.settingsPageSyncButtonCallBack;
                            passwordSyncClient.fnErrorCallBack = this.settingsPageSyncButtonErrorCallBack;
                            passwordSyncClient.url = "ws://"+syncPageServerIPTextField.text+":3002";
                            passwordSyncClient.active = true;
                        }

                        function settingsPageSyncButtonErrorCallBack()
                        {
                            settingsPageSyncButtonCallBack();
                        }

                        function settingsPageSyncButtonCallBack()
                        {
                            syncPageBusyIndicator.visible = false;
                            syncPageBackButton.enabled = true;
                            syncPageSyncButton.enabled = true;
                            syncPageServerIPTextField.enabled = true;
                            syncPageSyncMethodComboBox.enabled = true
                            passwordSyncClient.active = false;
                        }
                    }
                }
            }
        }

        Component {
            id: changePasswordPage

            Item {
                id: changePasswordPageRectangle
                //color: "transparent"
                //visible: false

                ScrollView {
                    id: changePasswordPageScrollView

                    anchors {
                        right: parent.right
                        top: parent.top
                        left: parent.left
                        bottom: changePasswordPageBottomRowLayout.top
                    }

                    BusyIndicator {
                        id: changePasswordPageBusyIndicator
                        anchors.centerIn: parent
                        visible: false
                        running: true
                    }

                    ColumnLayout {
                        spacing: 2
                        anchors.fill: parent

                        anchors.margins: 10

                        Label {
                            text: "Old password"
                        }
                        TextField {
                            id: changePasswordPageOldPasswordTextField
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignJustify

                            focus: true
                            text: stackView.changePasswordPageOldPasswordText
                            selectByMouse: true
                            echoMode: TextInput.Password
                        }
                        Label {
                            text: "New password"
                        }
                        TextField {
                            id: changePasswordPageNewPasswordTextField
                            Layout.fillWidth: true
                            Layout.alignment: Qt.AlignJustify

                            focus: true
                            text: stackView.changePasswordPageNewPasswordText
                            selectByMouse: true
                            echoMode: TextInput.Password
                        }
                        Label {
                            id: changePasswordPageStatusLabel
                            text: "Status:"
                        }
                        Item { Layout.fillHeight: true }
                    }
                }

                RowLayout {
                    id: changePasswordPageBottomRowLayout

                    anchors {
                        right: parent.right
                        bottom: parent.bottom
                        left: parent.left
                    }

                    Button {
                        id: changePasswordPageBackButton

                        Layout.fillWidth: true
                        text: "Back"

                        onClicked: {
                            stackView.pop();
                        }
                    }

                    Button {
                        id: changePasswordPageSaveButton

                        Layout.fillWidth: true
                        text: "Save"

                        onClicked: {
                            changePasswordPageBusyIndicator.visible = true;
                            changePasswordPageBackButton.enabled = false;
                            changePasswordPageSaveButton.enabled = false;
                            changePasswordPageOldPasswordTextField.enabled = false;
                            changePasswordPageNewPasswordTextField.enabled = false;
                            /*
                            passwordSyncClient.sCommand = "SYNC_"+oSettingsModel.fnGetStringValue("syncPageSyncMethod");
                            passwordSyncClient.fnCallBack = this.settingsPageSyncButtonCallBack;
                            passwordSyncClient.fnErrorCallBack = this.settingsPageSyncButtonErrorCallBack;
                            passwordSyncClient.url = "ws://"+syncPageServerIPTextField.text+":3002";
                            passwordSyncClient.active = true;
                            */

                            if (changePasswordPageNewPasswordTextField.text.length >= 8) {
                                if (changePasswordPageOldPasswordTextField.text == oPasswordListModel.fnGetPassword()) {
                                    oPasswordListModel.fnSetPassword(changePasswordPageNewPasswordTextField.text);
                                    changePasswordPageStatusLabel.text = "Status: password changed"
                                } else {
                                    changePasswordPageStatusLabel.text = "Status: wrong old password"
                                }
                            } else {
                                changePasswordPageStatusLabel.text = "Status: new password can't less than 8 symbols"
                            }

                            settingsPageSyncButtonCallBack();
                        }

                        function settingsPageSyncButtonErrorCallBack()
                        {
                            settingsPageSyncButtonCallBack();
                        }

                        function settingsPageSyncButtonCallBack()
                        {
                            changePasswordPageBusyIndicator.visible = false;
                            changePasswordPageBackButton.enabled = true;
                            changePasswordPageSaveButton.enabled = true;
                            changePasswordPageOldPasswordTextField.enabled = true;
                            changePasswordPageNewPasswordTextField.enabled = true;
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
