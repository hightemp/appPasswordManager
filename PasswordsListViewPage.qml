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

            z: Infinity

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

            clip: true

            ListView {
                id: passwordsListView
                width: parent.width
                orientation: ListView.Vertical
                model: stackView.oPasswordsListViewModel
                focus: true

                highlightFollowsCurrentItem: false
                highlight: Rectangle {
                    opacity: 0.5
                    color: "skyblue"
                    width: ListView.view ? ListView.view.width : 0
                    height: ListView.view && ListView.view.currentItem ? ListView.view.currentItem.height : 0
                    y: ListView.view && ListView.view.currentItem ? ListView.view.currentItem.y : 0
                    //z: Infinity
                }

                FontMetrics {
                    id: passwordsListViewFontMetrics
                    font.pixelSize: 12
                }

                onCurrentIndexChanged: {
                    console.log('onCurrentIndexChanged');
                    stackView.iEditedRecordIndex = currentIndex;
                }

                delegate: Item {
                    id: passwordsListDelegate

                    property var view: ListView.view
                    property bool isCurrent: ListView.isCurrentItem

                    width: view.width
                    height: 20+
                            passwordsListViewFontMetrics.height*(oSettingsModel.fnGetBoolValue("settingsPageShowCreatedAtInList") ? 1 : 0)+
                            passwordsListViewFontMetrics.height*(oSettingsModel.fnGetBoolValue("settingsPageShowUpdatedAtInList") ? 1 : 0)+
                            passwordsListViewFontMetrics.height+
                            passwordsListViewFontMetrics.height*(
                                oSettingsModel.fnGetBoolValue("settingsPageShowUserInList")
                                || oSettingsModel.fnGetBoolValue("settingsPageShowPasswordInList")
                                || oSettingsModel.fnGetBoolValue("settingsPageShowIdInList")
                                ? 1 : 0
                            )

                    Label {
                        padding: 10
                        anchors.fill: parent
                        font.pixelSize: passwordsListViewFontMetrics.font.pixelSize
                        //anchors.centerIn: parent

                        renderType: Text.NativeRendering
                        text: (oSettingsModel.fnGetBoolValue("settingsPageShowCreatedAtInList") ? "Created: " + createdAt + "<br>" : "") +
                              (oSettingsModel.fnGetBoolValue("settingsPageShowUpdatedAtInList") ? "Updated: " + updatedAt + "<br>" : "") +
                              "<b>"+name+"</b>"+
                              (oSettingsModel.fnGetBoolValue("settingsPageShowUserInList") ||
                               oSettingsModel.fnGetBoolValue("settingsPageShowPasswordInList") ? "<br>" : "" ) +
                              (oSettingsModel.fnGetBoolValue("settingsPageShowIdInList") ? "<b>Id:</b> "+id+" " : "") +
                              (oSettingsModel.fnGetBoolValue("settingsPageShowUserInList") ? "<b>User:</b> "+user+" " : "") +
                              (oSettingsModel.fnGetBoolValue("settingsPageShowPasswordInList") ? "<b>Password:</b> "+password : "")
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
                        oExportFilesListModel.fnUpdate();
                        stackView.push(exportPage);
                    }
                }

                Button {
                    id: importButton
                    Layout.minimumWidth: (stackView.width)/2
                    text: "Import"
                    //Layout.fillWidth: true

                    onClicked: {
                        oImportFilesListModel.fnUpdate();
                        stackView.push(importPage);
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
                        stackView.settingsPageShowIdInList = oSettingsModel.fnGetBoolValue("settingsPageShowIdInList");
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
