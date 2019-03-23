import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import PasswordListModel 1.0

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
                        Layout.fillWidth: true
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
                    text: "Generate new password (will replace old)"
                }

                RowLayout {
                    spacing: 2

                    TextField {
                        id: generatedPasswordTextField
                        Layout.fillWidth: true
                        text: ''
                        readOnly: true
                        selectByMouse: true
                    }

                    Button {
                        id: passwordEditPageGeneratePasswordButton
                        text: "Generate"
                        onClicked: {
                            generatedPasswordTextField.text = oPasswordListModel.fnGenerateIndex();
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
                        Layout.minimumHeight: 100;

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
                        Layout.alignment: Qt.AlignLeft | Qt.AlignTop
                        onClicked: {
                            oClipboard.fnCopy(additionalTextArea.text);
                        }
                    }
                }
            }
        }

        BusyIndicator {
            id: passwordEditPageSyncBusyIndicator
            anchors.centerIn: parent
            z: 2
            visible: false
            enabled: true
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

                Layout.minimumWidth: (stackView.width)/2
                text: "Back"
                onClicked: {
                    stackView.pop();
                }
            }

            Button {
                id: passwordEditPageSaveButton

                Layout.minimumWidth: (stackView.width)/2
                text: "Save"

                property int iServerIndex: 0
                property int iServersCount;

                onClicked: {
                    if (stackView.bPasswordsListIsNewItem) {
                        stackView.iEditedRecordIndex = oPasswordListModel.fnAddRow();
                    }

                    var oIndex = oPasswordListModel.index(stackView.iEditedRecordIndex, 0);
                    oPasswordListModel.setData(oIndex, nameTextField.text, PasswordListModel.NameRole);
                    oPasswordListModel.setData(oIndex, userTextField.text, PasswordListModel.UserRole);
                    if (generatedPasswordTextField.text != '') {
                        oPasswordListModel.setData(oIndex, generatedPasswordTextField.text, PasswordListModel.PasswordRole);
                    } else {
                        oPasswordListModel.setData(oIndex, passwordTextField.text, PasswordListModel.PasswordRole);
                    }
                    oPasswordListModel.setData(oIndex, additionalTextArea.text, PasswordListModel.AdditionalRole);

                    if (oSettingsModel.fnGetBoolValue("settingsPageSynchronizeOnUpdate")) {
                        fnSyncOnUpdate();
                        return;
                    }

                    stackView.pop();
                }

                function fnSyncOnUpdate()
                {
                    console.log('fnSyncOnUpdate');
                    nameTextField.enabled = false;
                    passwordEditPageCopyNameButton.enabled = false;
                    userTextField.enabled = false;
                    passwordEditPageCopyUserButton.enabled = false;
                    passwordTextField.enabled = false;
                    passwordEditPageCopyPasswordButton.enabled = false;
                    generatedPasswordTextField.enabled = false;
                    passwordEditPageGeneratePasswordButton.enabled = false;
                    additionalTextArea.enabled = false;
                    passwordEditPageCopyAdditionalButton.enabled = false;
                    passwordEditPageBackButton.enabled = false;
                    passwordEditPageSaveButton.enabled = false;

                    passwordEditPageSyncBusyIndicator.visible = true;
                    iServerIndex = 0;
                    iServersCount = oServersListModel.fnSize();
                    fnSyncNext();
                }

                function fnSyncNext()
                {
                    console.log('fnSyncNext');
                    if (oServersListModel.fnGetBoolValue(iServerIndex, "isEnabled")) {
                        passwordSyncClient.sCommand = "SYNC_3";
                        passwordSyncClient.fnCallBack = this.passwordEditPageSyncButtonCallBack;
                        passwordSyncClient.fnErrorCallBack = this.passwordEditPageSyncButtonErrorCallBack;
                        passwordSyncClient.sHost = oServersListModel.fnGetStringValue(iServerIndex, "host", "127.0.0.1");
                        passwordSyncClient.sPort = oServersListModel.fnGetStringValue(iServerIndex, "port", "3002");
                        passwordSyncClient.url = "ws://"+
                                oServersListModel.fnGetStringValue(iServerIndex, "host", "127.0.0.1")+
                                ":"+
                                oServersListModel.fnGetStringValue(iServerIndex, "port", "3002");
                        iServerIndex++;
                        passwordSyncClient.active = true;
                    } else {
                        iServerIndex++;
                        passwordEditPageSyncButtonCallBack();
                    }
                }

                function passwordEditPageSyncButtonErrorCallBack(sErrorString)
                {
                    console.log('passwordEditPageSyncButtonErrorCallBack');
                    console.log('Error', iServerIndex, iServersCount);
                    passwordEditPageSyncButtonCallBack();
                }

                function passwordEditPageSyncButtonCallBack()
                {
                    console.log('passwordEditPageSyncButtonCallBack');
                    passwordSyncClient.active = false;
                    console.log(iServerIndex, iServersCount);
                    if (iServerIndex >= iServersCount) {
                        passwordEditPageSyncBusyIndicator.visible = false;

                        nameTextField.enabled = true;
                        passwordEditPageCopyNameButton.enabled = true;
                        userTextField.enabled = true;
                        passwordEditPageCopyUserButton.enabled = true;
                        passwordTextField.enabled = true;
                        passwordEditPageCopyPasswordButton.enabled = true;
                        generatedPasswordTextField.enabled = true;
                        passwordEditPageGeneratePasswordButton.enabled = true;
                        additionalTextArea.enabled = true;
                        passwordEditPageCopyAdditionalButton.enabled = true;
                        passwordEditPageBackButton.enabled = true;
                        passwordEditPageSaveButton.enabled = true;

                        stackView.pop();
                    } else {
                        fnSyncNext();
                    }
                }
            }
        }
    }
}
