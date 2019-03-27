import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3

Component {
    id: exportPage

    Item {
        id: exportPageRectangle

        RowLayout {
            id: exportPageTopRowLayout
            spacing: 2

            TextField {
                id: exportPagePathTextField
                Layout.fillWidth: true
                text: stackView.oExportFilesListModel.fnGetCurrentPath()
                selectByMouse: true
            }

            Button {
                id: exportPageUpButton
                text: "\u21E7"
                onClicked: {
                    oExportFilesListModel.fnUp();
                }
            }
        }

        ScrollView {
            id: exportPageScrollView
            anchors {
                right: parent.right
                top: exportPageTopRowLayout.bottom
                left: parent.left
                bottom: exportPageBottomColumnLayout.top
            }

            ListView {
                id: exportPageListView
                width: parent.width
                orientation: ListView.Vertical
                model: stackView.oExportFilesListModel
                focus: true

                highlight: Rectangle {
                    opacity: 0.5
                    color: "skyblue"
                }

                FontMetrics {
                    id: exportPageFontMetrics
                    font.pixelSize: 12
                }

                highlightFollowsCurrentItem: true

                delegate: Item {
                    id: exportPageDelegate

                    property var view: ListView.view
                    property bool isCurrent: ListView.isCurrentItem

                    width: view.width
                    height: 20+exportPageFontMetrics.height

                    Label {
                        padding: 10
                        anchors.fill: parent
                        font.pixelSize: exportPageFontMetrics.font.pixelSize
                        //anchors.centerIn: parent

                        renderType: Text.NativeRendering
                        text: fileName
                    }

                    MouseArea {
                        anchors.fill: parent

                        onClicked: {
                            view.currentIndex = model.index;
                            if (!model.isDir) {
                                exportPageFileNameTextField.text = fileName;
                            }
                        }

                        onDoubleClicked: {
                            view.currentIndex = model.index;
                            if (model.isDir) {
                                oExportFilesListModel.fnOpenDir(model.index);
                            } else {
                                exportPageFileNameTextField.text = fileName;
                            }
                        }
                    }
                }
            }
        }

        ColumnLayout {
            id: exportPageBottomColumnLayout

            anchors {
                right: parent.right
                bottom: parent.bottom
                left: parent.left
            }

            TextField {
                id: exportPageFileNameTextField
                Layout.fillWidth: true
                text: ''
                selectByMouse: true

                onTextChanged: {
                    if (text.indexOf('/')!=-1
                        || text.indexOf('\\')!=-1
                        || !text.length) {
                        exportPageExportButton.enabled = false;
                    } else {
                        exportPageExportButton.enabled = true;
                    }
                }
            }

            ComboBox {
                id: exportPageNameFilterComboBox
                Layout.fillWidth: true
                model: [ "JSON (*.json)", "TEXT (*.txt)" ]
            }

            RowLayout {
                Layout.fillHeight: true

                Button {
                    id: exportPageBackButton
                    Layout.minimumWidth: (stackView.width)/2
                    text: "Back"
                    //Layout.fillWidth: true

                    onClicked: {
                        stackView.pop();
                    }
                }

                Button {
                    id: exportPageExportButton
                    Layout.minimumWidth: (stackView.width)/2
                    text: "Export"
                    //Layout.fillWidth: true

                    enabled: false

                    property var oFilterExtension: [
                        ".json",
                        ".txt"
                    ]

                    onClicked: {
                        return;

                        oPasswordListModel.fnExport(
                            oExportFilesListModel.fnGetCurrentPath()+'/'+exportPageFileNameTextField.text+oFilterExtension[exportPageNameFilterComboBox.currentIndex],
                            exportPageNameFilterComboBox.currentIndex
                        );

                        stackView.pop();
                    }
                }
            }
        }

    }

}
