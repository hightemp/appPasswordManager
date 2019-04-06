import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

Component {
    id: settingsPage

    Item {
        id: settingsPageRectangle
        //color: "transparent"
        //visible: false

        Component.onCompleted: {
            console.log('settingsPage - onCompleted');
        }

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
                    id: settingsPageSynchronizeOnUpdate
                    text: "Upload and replace list on item save"
                    checked: stackView.settingsPageSynchronizeOnUpdate
                }
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
                CheckBox {
                    id: settingsPageShowCreatedAtInList
                    text: "Show creation time in list"
                    checked: stackView.settingsPageShowCreatedAtInList
                }
                CheckBox {
                    id: settingsPageShowUpdatedAtInList
                    text: "Show update time in list"
                    checked: stackView.settingsPageShowUpdatedAtInList
                }
                /*
                Label {
                    text: "Theme"
                }
                ComboBox {
                    id: settingsPageStyle
                    model: stackView.settingsPageStyleModel
                    currentIndex: stackView.settingsPageStyleCurrentIndex
                }
                */
                Label {
                    text: "Web sockets server listen ip and port"
                }
                RowLayout {
                    width: 300
                    Layout.minimumWidth: 300

                    TextField {
                        width: 200
                        id: settingsPageServerHost
                        placeholderText: "0.0.0.0"
                        text: stackView.settingsPageServerHostText

                        selectByMouse: true
                    }
                    TextField {
                        id: settingsPageServerPort
                        width: 100
                        placeholderText: "3002"
                        text: stackView.settingsPageServerPortText

                        selectByMouse: true
                    }
                }
                Label {
                    id: settingsPageServerStatusLabel
                    text: stackView.settingsPageServerStatusLabelText
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

                    Layout.minimumWidth: (stackView.width)/2
                    text: "Back"
                    onClicked: {
                        stackView.pop();
                    }
                }

                Button {
                    id: settingsPageSaveButton

                    Layout.minimumWidth: (stackView.width)/2
                    text: "Save"
                    onClicked: {
                        oSettingsModel.fnUpdateBoolValue("settingsPageSynchronizeOnUpdate", settingsPageSynchronizeOnUpdate.checked);
                        oSettingsModel.fnUpdateBoolValue("settingsPageShowCreatedAtInList", settingsPageShowCreatedAtInList.checked);
                        oSettingsModel.fnUpdateBoolValue("settingsPageShowUpdatedAtInList", settingsPageShowUpdatedAtInList.checked);
                        oSettingsModel.fnUpdateBoolValue("settingsPageShowUserInList", settingsPageShowUserInList.checked);
                        oSettingsModel.fnUpdateBoolValue("settingsPageShowPasswordInList", settingsPageShowPasswordsInList.checked);
                        //oSettingsModel.fnUpdateIntValue("settingsPageStyle", settingsPageStyle.currentIndex);
                        oSettingsModel.fnUpdateStringValue("settingsPageServerHost", settingsPageServerHost.text);
                        oSettingsModel.fnUpdateStringValue("settingsPageServerPort", settingsPageServerPort.text);
                        passwordSyncServer.onListenChanged.connect(settingsPageSaveButton.fnOnSettingsPageSaveButton);
                        passwordSyncServer.host = settingsPageServerHost.text;
                        passwordSyncServer.port = settingsPageServerPort.text;
                        console.log('passwordSyncServer.listen', passwordSyncServer.listen);
                        //oStyler.fnSetStyle(settingsPageStyle.currentText);
                        //oPasswordListModel.fnUpdate();
                        //oSettingsModel.fnSave();
                        //stackView.pop();
                    }

                    function fnOnSettingsPageSaveButton()
                    {
                        passwordSyncServer.onListenChanged.disconnect(settingsPageSaveButton.fnOnSettingsPageSaveButton);
                        passwordSyncServer.listen = true;
                        console.log('fnOnSettingsPageSaveButton passwordSyncServer.listen', passwordSyncServer.listen);
                        oPasswordListModel.fnUpdate();
                        oSettingsModel.fnSave();
                    }
                }
            }
        }

    }
}

