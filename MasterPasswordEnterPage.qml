import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

Component {
    id: masterPasswordEnterPage

    Item {
        property var defaultFocusItem: masterPasswordField
        ColumnLayout {
            anchors.centerIn: parent
            Layout.maximumWidth: 300

            Label {
                text: "Enter master-password"
            }
            TextField {
                id: masterPasswordField
                focus: true
                selectByMouse: true

                Layout.minimumWidth: 300
                text: ""
                echoMode: TextInput.Password

                Keys.onEnterPressed: {
                    masterPasswordEnterPageEnterButton.fnEnter();
                }
                Keys.onReturnPressed: {
                    masterPasswordEnterPageEnterButton.fnEnter();
                }
            }
            Label {
                id: masterPasswordEnterPageStatusLabel
                Layout.maximumWidth: 300
                wrapMode: "WordWrap"
                text: stackView.masterPasswordEnterPageStatusLabelText
            }
        }

        RowLayout {
            id: masterPasswordEnterPageBottomRowLayout

            anchors {
                right: parent.right
                bottom: parent.bottom
                left: parent.left
            }

            Button {
                id:masterPasswordEnterPageCloseButton

                Layout.minimumWidth: (stackView.width)/2
                text: "Close"
                onClicked: {
                    Qt.quit();
                }
            }

            Button {
                id: masterPasswordEnterPageEnterButton

                Layout.minimumWidth: (stackView.width)/2
                text: "Enter"
                onClicked: fnEnter()

                function fnEnter() {
                    Qt.inputMethod.hide();

                    if (masterPasswordField.text.length<8) {
                        masterPasswordEnterPageStatusLabel.text = "Password must be 8 symbols length minimum";
                        return;
                    }

                    oPasswordListModel.fnSetPassword(masterPasswordField.text);
                    var iLoadResult = oPasswordListModel.fnLoad();

                    if (iLoadResult == 0) {
                        var iSaveResult = oPasswordListModel.fnSave();
                    }

                    if (iLoadResult < 0 || iSaveResult<0) {
                        if (iSaveResult == -1) {
                            masterPasswordEnterPageStatusLabel.text = "Can't open file %1 for writing".arg(oPasswordListModel.fnGetFilePath());
                        }
                        if (iSaveResult == -10) {
                            masterPasswordEnterPageStatusLabel.text = "Key is empty";
                        }
                        if (iSaveResult == -20) {
                            masterPasswordEnterPageStatusLabel.text = "Encrypted string is empty";
                        }
                        if (iLoadResult == -1) {
                            masterPasswordEnterPageStatusLabel.text = "Can't open file %1 for reading".arg(oPasswordListModel.fnGetFilePath());
                        }
                        if (iLoadResult == -2) {
                            masterPasswordEnterPageStatusLabel.text = "Wrong json format in %1".arg(oPasswordListModel.fnGetFilePath());
                        }
                        if (iLoadResult == -10) {
                            masterPasswordEnterPageStatusLabel.text = "Key is empty";
                        }
                        if (iLoadResult == -20) {
                            masterPasswordEnterPageStatusLabel.text = "Encrypted string is empty";
                        }
                        if (iLoadResult == -30) {
                            masterPasswordEnterPageStatusLabel.text = "Can't decrypt passwords file. Master-password is wrong.";
                        }
                        return;
                    }

                    stackView.oPasswordsListViewModel = oPasswordListSortFilterProxyModel;
                    stackView.oServersListViewModel = oServersListModel;
                    passwordSyncServer.host = oSettingsModel.fnGetStringValue("settingsPageServerHost", "0.0.0.0");
                    passwordSyncServer.port = oSettingsModel.fnGetStringValue("settingsPageServerPort", "3002");
                    passwordSyncServer.listen = true;
                    stackView.push(passwordsListViewPage);
                }
            }
        }
    }
}
