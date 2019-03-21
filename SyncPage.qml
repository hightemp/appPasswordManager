import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

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
                bottom: syncPageBottomColumnLayout.top
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
                    wrapMode: Text.WordWrap
                }

                Label {
                    id: syncPageErrorLabel
                    padding: 10

                    text: ''
                }

                Item { Layout.fillHeight: true }
            }
        }

        ColumnLayout {
            id: syncPageBottomColumnLayout

            anchors {
                right: parent.right
                bottom: parent.bottom
                left: parent.left
            }

            RowLayout {
                Button {
                    id: syncPageServersListButton

                    Layout.fillWidth: true
                    text: "Synchronization servers list"
                    onClicked: {
                        stackView.push(serversListViewPage);
                    }
                }
            }

            RowLayout {
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
                    property int iServerIndex: 0
                    property int iServersCount;

                    Layout.fillWidth: true
                    text: "Sync"
                    onClicked: {
                        syncPageBackButton.enabled = false;
                        syncPageSyncButton.enabled = false;
                        syncPageServersListButton.enabled = false;
                        syncPageSyncMethodComboBox.enabled = false
                        syncPageBusyIndicator.visible = true;
                        syncPageErrorLabel.text = '';
                        iServerIndex = 0;
                        iServersCount = oServersListModel.fnSize();
                        fnSyncNext();
                    }

                    function fnSyncNext()
                    {
                        if (oServersListModel.fnGetBoolValue(iServerIndex, "isEnabled")) {
                            passwordSyncClient.sCommand = "SYNC_"+oSettingsModel.fnGetStringValue("syncPageSyncMethod");
                            passwordSyncClient.fnCallBack = this.settingsPageSyncButtonCallBack;
                            passwordSyncClient.fnErrorCallBack = this.settingsPageSyncButtonErrorCallBack;
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
                            settingsPageSyncButtonCallBack();
                        }
                    }

                    function settingsPageSyncButtonErrorCallBack(sErrorString)
                    {
                        console.log('Error', iServerIndex, iServersCount);
                        //iServerIndex = iServersCount;
                        syncPageErrorLabel.text += sErrorString + '<br>';
                        settingsPageSyncButtonCallBack();
                    }

                    function settingsPageSyncButtonCallBack()
                    {
                        passwordSyncClient.active = false;
                        console.log(iServerIndex, iServersCount);
                        if (iServerIndex >= iServersCount) {
                            syncPageBusyIndicator.visible = false;
                            syncPageBackButton.enabled = true;
                            syncPageSyncButton.enabled = true;
                            syncPageServersListButton.enabled = true;
                            syncPageSyncMethodComboBox.enabled = true;
                        } else {
                            fnSyncNext();
                        }
                    }
                }
            }
        }


    }
}
