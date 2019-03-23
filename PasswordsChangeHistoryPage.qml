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
            id: passwordsChangeHistoryPageScrollView
            anchors {
                right: parent.right
                top: passwordsChangeHistoryPageFilterTextField.bottom
                left: parent.left
                bottom: passwordsChangeHistoryPageBottomColumnLayout.top
            }

            ListView {
                id: passwordsChangeHistoryPageListView
                width: parent.width
                orientation: ListView.Vertical
                model: stackView.oHistoryListViewModel
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
                    id: passwordsChangeHistoryPageListViewItemDelegate

                    property var view: ListView.view
                    property bool isCurrent: ListView.isCurrentItem

                    width: view.width
                    height: 60

                    Label {
                        padding: 10
                        anchors.fill: parent
                        //anchors.centerIn: parent

                        renderType: Text.NativeRendering
                        text: "<b>Name:</b>"+name+"<br>"+
                              "<b>User:</b>"+user+"<br>"+
                              "<b>Password:</b> "+password+"<br>"+
                              "<b>Additional:</b> "+additional;
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

                    }
                }

                Button {
                    id: passwordsChangeHistoryPageDeleteButton
                    Layout.minimumWidth: (stackView.width)/2
                    text: "Delete"
                    //Layout.fillWidth: true

                    onClicked: {

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

                    }
                }
            }

        }
    }
}
