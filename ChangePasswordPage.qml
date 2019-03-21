import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

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
