import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

Component {
    id: serversListViewPage

    Item {
        id: serversListViewPageRectangle
        //color: "transparent"
        anchors.fill: parent


        ScrollView {
            id: serversListViewPageScrollView
            anchors {
                right: parent.right
                top: parent.top
                left: parent.left
                bottom: serversListViewPageBottomColumnLayout.top
            }
            ListView {
                id: serversListView
                width: parent.width
                //orientation: ListView.Vertical
                model: stackView.oServersListViewModel
                focus: true

                highlight: Rectangle {
                    color: "skyblue"
                }

                highlightFollowsCurrentItem: true

                delegate: Item {
                    id: serversListDelegate

                    property var serversListDelegateView: ListView.view
                    property bool serversListDelegateIsCurrent: ListView.isCurrentItem

                    width: serversListDelegateView.width
                    height: 60

                    function fnServersListViewSelectCurrentItem()
                    {
                        serversListDelegateView.currentIndex = model.index;
                    }

                    MouseArea {
                        anchors.fill: parent
                        z: RowLayout.z-1

                        onClicked: {
                            fnServersListViewSelectCurrentItem();
                        }
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 10

                        CheckBox {
                            id: serversListDelegateIsEnabled
                            checked: model.isEnabled

                            onCheckStateChanged: model.isEnabled = checked

                            onClicked: {
                                fnServersListViewSelectCurrentItem();
                            }
                        }
                        TextField {
                            id: serversListDelegateServerHost
                            placeholderText: "127.0.0.1"
                            enabled: true

                            text: model.host
                            onEditingFinished: model.host = text
                            selectByMouse: true

                            onFocusChanged: {
                                if (focus) {
                                    fnServersListViewSelectCurrentItem();
                                }
                            }
                        }
                        TextField {
                            id: serversListDelegateServerPort
                            width: 100

                            placeholderText: "3002"
                            text: model.port
                            onEditingFinished: model.port = text
                            selectByMouse: true

                            Layout.fillWidth: true

                            onFocusChanged: {
                                if (focus) {
                                    fnServersListViewSelectCurrentItem();
                                }
                            }
                        }
                    }
                }
            }

        }

        ColumnLayout {
            id: serversListViewPageBottomColumnLayout

            anchors {
                right: parent.right
                bottom: parent.bottom
                left: parent.left
            }

            RowLayout {
                Layout.fillHeight: true

                Button {
                    id: serversListViewPageAddButton
                    //Layout.minimumWidth: (parent.width-20)/2 + 1
                    text: "Add"
                    Layout.fillWidth: true

                    onClicked: {
                        oServersListModel.fnAddRow();
                    }
                }

                Button {
                    id: serversListViewPageDeleteButton
                    //Layout.minimumWidth: (parent.width-20)/2 + 1
                    text: "Delete"
                    Layout.fillWidth: true

                    onClicked: {
                        oServersListModel.fnRemoveRow(serversListView.currentIndex);
                    }
                }
            }

            RowLayout {
                Layout.fillHeight: true

                Button {
                    id: serversListViewPageBackButton
                    //Layout.minimumWidth: (parent.width-20)/2 + 1
                    text: "Back"
                    Layout.fillWidth: true

                    onClicked: {
                        stackView.pop();
                    }
                }

                Button {
                    id: serversListViewPageSaveButton
                    //Layout.minimumWidth: (parent.width-20)/2 + 1
                    text: "Save"
                    Layout.fillWidth: true

                    onClicked: {
                        oServersListModel.fnSave();
                    }
                }
            }

        }

    }
}
