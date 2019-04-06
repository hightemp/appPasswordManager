import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Dialogs 1.2
import QtQuick.Window 2.0

Component {
    id: passwordsChangeHistoryPage

    Item {
        id: passwordsChangeHistoryPageItem

        TextField {
            id: passwordsChangeHistoryPageFilterTextField

            z: Infinity

            anchors {
                right: parent.right
                top: parent.top
                left: parent.left
            }

            selectByMouse: true
            placeholderText: "Filter.."

            onTextChanged: {
                oPasswordChangeHistoryListSortFilterProxyModel.setFilterFixedString(text);
            }
        }

        ScrollView {
            id: passwordsChangeHistoryPageScrollView
            anchors {
                right: parent.right
                top: passwordsChangeHistoryPageFilterTextField.bottom
                left: parent.left
                bottom: passwordsChangeHistoryPageBottomColumnLayout.top
            }

            clip: true

            ListView {
                id: passwordsChangeHistoryPageListView
                width: parent.width
                orientation: ListView.Vertical
                model: stackView.oPasswordsChangeHistoryListViewModel
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
                    id: passwordsChangeHistoryPageListViewFontMetrics
                    font.pixelSize: 10
                }

                onCurrentIndexChanged: {
                    console.log('onCurrentIndexChanged');
                    stackView.iHistroyRecordIndex = currentIndex;
                }

                delegate: Item {
                    id: passwordsChangeHistoryPageListViewItemDelegate

                    property var view: ListView.view
                    property bool isCurrent: ListView.isCurrentItem

                    width: view.width
                    height: 20+6*passwordsChangeHistoryPageListViewFontMetrics.height

                    Label {
                        padding: 10
                        anchors.fill: parent
                        font.pixelSize: passwordsChangeHistoryPageListViewFontMetrics.font.pixelSize
                        //anchors.centerIn: parent

                        renderType: Text.NativeRendering
                        text: "<b>Event time:</b> "+timestamp+"<br>"+
                              "<b>Event type:</b> "+eventType+"<br>"+
                              "<b>Id:</b> "+id+"<br>"+
                              "<b>Name:</b> "+name+"<br>"+
                              "<b>User:</b> "+user+"<br>"+
                              "<b>Password:</b> "+password+"<br>"//+
                              //"<b>Additional:</b> "+additional;
                    }

                    MouseArea {
                        anchors.fill: parent

                        onClicked: {
                            view.currentIndex = model.index;
                        }
                    }
                }

            }
        }

        ColumnLayout {
            id: passwordsChangeHistoryPageBottomColumnLayout

            anchors {
                right: parent.right
                bottom: parent.bottom
                left: parent.left
            }

            RowLayout {
                Layout.fillHeight: true

                Button {
                    id: passwordsChangeHistoryPageRestoreButton
                    Layout.minimumWidth: (stackView.width)/2
                    text: "Restore"
                    //Layout.fillWidth: true

                    onClicked: {
                        oPasswordChangeHistoryListModel.fnRestore(stackView.iHistroyRecordIndex);
                        oPasswordListModel.fnSave();
                    }
                }

                Button {
                    id: passwordsChangeHistoryPageDeleteButton
                    Layout.minimumWidth: (stackView.width)/2
                    text: "Delete"
                    //Layout.fillWidth: true

                    onClicked: {
                        passwordsChangeHistoryPageDeleteItemDialog.open();
                    }
                }
            }

            RowLayout {
                Layout.fillHeight: true

                Button {
                    id: passwordsChangeHistoryPageBackButton
                    Layout.minimumWidth: (stackView.width)/2
                    text: "Back"
                    //Layout.fillWidth: true

                    onClicked: {
                        stackView.pop();
                    }
                }

                Button {
                    id: passwordsChangeHistoryPageClearButton
                    Layout.minimumWidth: (stackView.width)/2
                    text: "Clear"
                    //Layout.fillWidth: true

                    onClicked: {
                        oPasswordChangeHistoryListModel.fnClear();
                        oPasswordListModel.fnSave();
                    }
                }
            }

        }

        MessageDialog {
            id: passwordsChangeHistoryPageDeleteItemDialog
            title: qsTr("Delete item?")
            standardButtons: Dialog.No | Dialog.Yes
            text: "Delete item?"

            onYes: {
                oPasswordChangeHistoryListModel.fnRemoveRow(stackView.iHistroyRecordIndex);
                oPasswordListModel.fnSave();
            }
        }
    }
}
