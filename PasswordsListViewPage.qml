import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Window 2.0
import QtQuick.Dialogs 1.2

Component {
    id: passwordsListViewPage

    Item {
        id: passwordsListViewRectangle
        //color: "transparent"

        TextField {
            id: passwordsListViewPageFilterTextField

            anchors {
                right: parent.right
                top: parent.top
                left: parent.left
            }

            selectByMouse: true
            placeholderText: "Filter.."

            onTextChanged: {
                oPasswordListSortFilterProxyModel.setFilterFixedString(text);
            }
        }

        ScrollView {
            id: passwordsListViewScrollView
            anchors {
                right: parent.right
                top: passwordsListViewPageFilterTextField.bottom
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
                    opacity: 0.5
                    color: "skyblue"
                }
                highlightFollowsCurrentItem: true
                onCurrentIndexChanged: {
                    console.log('onCurrentIndexChanged');
                    stackView.iEditedRecordIndex = currentIndex;
                }
                delegate: Item {
                    id: passwordsListDelegate

                    property var view: ListView.view
                    property bool isCurrent: ListView.isCurrentItem

                    width: view.width
                    height: 50

                    Label {
                        padding: 10
                        anchors.fill: parent
                        //anchors.centerIn: parent

                        renderType: Text.NativeRendering
                        text: (oSettingsModel.fnGetBoolValue("settingsPageShowCreatedAtInList") ? "Created: " + createdAt + " " : "") +
                              (oSettingsModel.fnGetBoolValue("settingsPageShowUpdatedAtInList") ? "Updated: " + updatedAt + " " : "") +
                              "<b>"+name+"</b>"+
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
                            stackView.iEditedRecordIndex = model.sourceIndex;
                            stackView.bPasswordsListIsNewItem = false;

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
                    id: historyButton
                    //Layout.minimumWidth: (parent.width-20)/2 + 1
                    text: "History"
                    Layout.fillWidth: true

                    onClicked: {
                        stackView.push(passwordsChangeHistoryPage);
                    }
                }
            }

            RowLayout {
                Layout.fillHeight: true

                Button {
                    id: exportButton
                    Layout.minimumWidth: (stackView.width)/2
                    text: "Export"
                    //Layout.fillWidth: true

                    onClicked: {
                        //passwordsListViewPageExportFileDialog.folder = sStandardPath;
                        passwordsListViewPageExportFileDialog.open();
                    }
                }

                Button {
                    id: importButton
                    Layout.minimumWidth: (stackView.width)/2
                    text: "Import"
                    //Layout.fillWidth: true

                    onClicked: {
                        //passwordsListViewPageImportFileDialog.folder = sStandardPath;
                        passwordsListViewPageImportFileDialog.open();
                    }
                }

                FileDialog {
                    id: passwordsListViewPageExportFileDialog
                    title: 'Export'
                    folder: shortcuts.home
                    nameFilters: [ "JSON (*.json)", "TEXT (*.txt)" ]
                    selectMultiple: false
                    selectExisting: false

                    onAccepted: {
                        console.log('Export', passwordsListViewPageExportFileDialog.fileUrls, passwordsListViewPageExportFileDialog.fileUrl);
                        oPasswordListModel.fnExport(passwordsListViewPageExportFileDialog.fileUrl);
                    }
                }

                FileDialog {
                    id: passwordsListViewPageImportFileDialog
                    title: 'Import'
                    folder: shortcuts.home
                    nameFilters: [ "JSON (*.json)", "TEXT (*.txt)" ]
                    selectMultiple: false
                    selectExisting: true

                    onAccepted: {
                        console.log('Import', passwordsListViewPageImportFileDialog.fileUrls, passwordsListViewPageImportFileDialog.fileUrl);
                        oPasswordListModel.fnImport(passwordsListViewPageImportFileDialog.fileUrl);
                    }
                }
            }

            RowLayout {
                Layout.fillHeight: true

                Button {
                    id: addButton
                    Layout.minimumWidth: (stackView.width)/2
                    text: "Add"
                    //Layout.fillWidth: true

                    onClicked: {
                        //stackView.iEditedRecordIndex = -1;
                        stackView.bPasswordsListIsNewItem = true;
                        stackView.sName = "";
                        stackView.sUser = "";
                        stackView.sPassword = "";
                        stackView.sAdditional = "";

                        stackView.push(passwordEditPage);
                    }
                }

                Button {
                    id: deleteButton
                    Layout.minimumWidth: (stackView.width)/2
                    text: "Delete"
                    //Layout.fillWidth: true

                    onClicked: {
                        passwordsListViewPageDeleteItemDialog.open();
                    }
                }

            }

            RowLayout {
                Layout.fillHeight: true

                Button {
                    id: syncButton
                    Layout.minimumWidth: (stackView.width)/2
                    text: "Synchronize"
                    //Layout.fillWidth: true

                    onClicked: {
                        stackView.syncPageServerIP = oSettingsModel.fnGetStringValue("syncPageServerIP");
                        stackView.syncPageSyncMethod = oSettingsModel.fnGetStringValue("syncPageSyncMethod");

                        stackView.push(syncPage);
                    }
                }

                Button {
                    id: settingsButton
                    Layout.minimumWidth: (stackView.width)/2
                    text: "Settings"
                    //Layout.fillWidth: true

                    onClicked: {
                        stackView.settingsPageSynchronizeOnUpdate = oSettingsModel.fnGetBoolValue("settingsPageSynchronizeOnUpdate");
                        stackView.settingsPageShowCreatedAtInList = oSettingsModel.fnGetBoolValue("settingsPageShowCreatedAtInList");
                        stackView.settingsPageShowUpdatedAtInList = oSettingsModel.fnGetBoolValue("settingsPageShowUpdatedAtInList");
                        stackView.settingsPageShowUserInList = oSettingsModel.fnGetBoolValue("settingsPageShowUserInList");
                        stackView.settingsPageShowPasswordInList = oSettingsModel.fnGetBoolValue("settingsPageShowPasswordInList");
                        //stackView.settingsPageStyleCurrentIndex = oSettingsModel.fnGetIntValue("settingsPageStyle");
                        stackView.settingsPageServerHostText = oSettingsModel.fnGetStringValue("settingsPageServerHost", "0.0.0.0");
                        stackView.settingsPageServerPortText = oSettingsModel.fnGetStringValue("settingsPageServerPort", "3002");
                        //stackView.settingsPageStyleModel = oStyler.fnGetStylesList();

                        stackView.push(settingsPage);
                    }
                }
            }
        }

        MessageDialog {
            id: passwordsListViewPageDeleteItemDialog
            title: qsTr("Delete item?")
            standardButtons: Dialog.No | Dialog.Yes
            text: "Delete item?"

            onYes: {
                oPasswordListModel.fnRemoveRow(stackView.iEditedRecordIndex);
            }
        }
    }
}
