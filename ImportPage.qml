import QtQuick 2.9
import QtQuick.Controls 2.2
import QtQuick.Layouts 1.3
import QtQuick.Controls.Styles 1.4

Component {
    id: importPage

    Item {
        id: importPageRectangle

        RowLayout {
            id: importPageTopRowLayout
            spacing: 2
            width: parent.width
            z: Infinity

            TextField {
                id: importPagePathTextField

                Layout.fillWidth: true
                text: stackView.oImportFilesListModel.fnGetCurrentPath()
                selectByMouse: true

                anchors {

                }

                Keys.onEnterPressed: {
                    oImportFilesListModel.fnSetPath(importPagePathTextField.text);
                    oImportFilesListModel.fnUpdate();
                }
                Keys.onReturnPressed: {
                    oImportFilesListModel.fnSetPath(importPagePathTextField.text);
                    oImportFilesListModel.fnUpdate();
                }
            }

            Button {
                id: importPageUpButton
                text: "Up"

                onClicked: {
                    oImportFilesListModel.fnUp();
                    importPagePathTextField.text = oImportFilesListModel.fnGetCurrentPath();
                    oImportFilesListModel.fnUpdate();
                }
            }

        }

        ScrollView {
            id: importPageScrollView
            anchors {
                right: parent.right
                top: importPageTopRowLayout.bottom
                left: parent.left
                bottom: importPageBottomColumnLayout.top
            }

            clip: true

            padding: {
                top: 2
                bottom: 2
            }

            ListView {
                id: importPageListView
                width: parent.width
                orientation: ListView.Vertical
                model: stackView.oImportFilesListModel
                focus: true

                highlightFollowsCurrentItem: false
                highlight: Rectangle {
                    opacity: 0.5
                    color: "skyblue"
                    width: ListView.view ? ListView.view.width : 0
                    height: 20+importPageFontMetrics.height
                    y: ListView.view && ListView.view.currentItem ? ListView.view.currentItem.y : 0
                    //z: Infinity
                }

                FontMetrics {
                    id: importPageFontMetrics
                    font.pixelSize: 12
                }

                delegate: Item {
                    id: importPageDelegate

                    property var view: ListView.view
                    property bool isCurrent: ListView.isCurrentItem

                    width: view.width
                    height: 20+importPageFontMetrics.height

                    Image {
                        id: icon
                        source: isDir ? "qrc:/images/folder.svg" : "qrc:/images/none.svg"
                        width: 32
                        height: 32
                        anchors {
                            left: parent.left
                        }
                    }

                    Label {
                        padding: 10
                        anchors {
                            top: parent.top
                            left: icon.right
                            bottom: parent.bottom
                            right: parent.right
                        }

                        font.pixelSize: importPageFontMetrics.font.pixelSize
                        //anchors.centerIn: parent

                        renderType: Text.NativeRendering
                        text: fileName
                    }

                    MouseArea {
                        anchors.fill: parent

                        onClicked: {
                            view.currentIndex = model.index;

                            if (!model.isDir) {
                                importPageFileNameTextField.text = fileName;
                            }

                        }

                        onDoubleClicked: {
                            view.currentIndex = model.index;

                            if (model.isDir) {
                                oImportFilesListModel.fnOpenDir(model.index);
                                importPagePathTextField.text = oImportFilesListModel.fnGetCurrentPath();
                            } else {
                                importPageFileNameTextField.text = fileName;
                            }

                            oImportFilesListModel.fnUpdate();
                        }
                    }
                }
            }
        }

        ColumnLayout {
            id: importPageBottomColumnLayout

            anchors {
                right: parent.right
                bottom: parent.bottom
                left: parent.left
            }

            TextField {
                id: importPageFileNameTextField
                Layout.fillWidth: true
                text: ''
                selectByMouse: true

                onTextChanged: {
                    if (text.indexOf('/')!=-1
                        || text.indexOf('\\')!=-1
                        || !text.length) {
                        importPageImportButton.enabled = false;
                    } else {
                        importPageImportButton.enabled = true;
                    }
                }
            }

            ComboBox {
                id: importPageNameFilterComboBox
                Layout.fillWidth: true
                model: [ "JSON Replace (*.json)", "JSON Merge (*.json)", "JSON Add (*.json)", "TEXT Replace (*.txt)", "TEXT Merge (*.txt)", "TEXT Add (*.txt)" ]

                delegate: ItemDelegate {
                    id: control
                    width: parent.width

                    contentItem: Text {
                        text: modelData
                        color: "#000000"
                        font: control.font
                        elide: Text.ElideRight
                        verticalAlignment: Text.AlignVCenter
                    }

                    background: Rectangle {
                        anchors.fill: control
                        color: control.highlighted ? "skyblue" : "transparent"
                    }

                    highlighted: importPageNameFilterComboBox.highlightedIndex === index
                }
            }

            RowLayout {
                Layout.fillHeight: true

                Button {
                    id: importPageBackButton
                    Layout.minimumWidth: (stackView.width)/2
                    text: "Back"
                    //Layout.fillWidth: true

                    onClicked: {
                        stackView.pop();
                    }
                }

                Button {
                    id: importPageImportButton
                    Layout.minimumWidth: (stackView.width)/2
                    text: "Import"
                    //Layout.fillWidth: true

                    enabled: false

                    onClicked: {
                        console.log('Import button clicked', oImportFilesListModel.fnGetCurrentPath(), importPageFileNameTextField.text);
                        oPasswordListModel.fnImport(
                            oImportFilesListModel.fnGetCurrentPath()+'/'+importPageFileNameTextField.text,
                            importPageNameFilterComboBox.currentIndex
                        );

                        oImportFilesListModel.fnUpdate();

                        stackView.pop();
                    }
                }
            }
        }

    }

}

