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
            width: parent.width
            z: Infinity

            TextField {
                id: exportPagePathTextField

                Layout.fillWidth: true
                text: stackView.oExportFilesListModel.fnGetCurrentPath()
                selectByMouse: true

                anchors {

                }

                Keys.onEnterPressed: {
                    oExportFilesListModel.fnSetPath(exportPagePathTextField.text);
                    oExportFilesListModel.fnUpdate();
                }
                Keys.onReturnPressed: {
                    oExportFilesListModel.fnSetPath(exportPagePathTextField.text);
                    oExportFilesListModel.fnUpdate();
                }
            }

            Button {
                id: exportPageUpButton
                text: "Up"

                onClicked: {
                    oExportFilesListModel.fnUp();
                    exportPagePathTextField.text = oExportFilesListModel.fnGetCurrentPath();
                    oExportFilesListModel.fnUpdate();
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

            clip: true

            padding: {
                top: 2
                bottom: 2
            }

            ListView {
                id: exportPageListView
                width: parent.width
                orientation: ListView.Vertical
                model: stackView.oExportFilesListModel
                focus: true

                highlightFollowsCurrentItem: false
                highlight: Rectangle {
                    opacity: 0.5
                    color: "skyblue"
                    width: ListView.view ? ListView.view.width : 0
                    height: 20+exportPageFontMetrics.height
                    y: ListView.view && ListView.view.currentItem ? ListView.view.currentItem.y : 0
                    //z: Infinity
                }

                FontMetrics {
                    id: exportPageFontMetrics
                    font.pixelSize: 12
                }

                delegate: Item {
                    id: exportPageDelegate

                    property var view: ListView.view
                    property bool isCurrent: ListView.isCurrentItem

                    width: view.width
                    height: 20+exportPageFontMetrics.height

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

                        font.pixelSize: exportPageFontMetrics.font.pixelSize
                        //anchors.centerIn: parent

                        renderType: Text.NativeRendering
                        text: fileName
                    }

                    MouseArea {
                        anchors.fill: parent

                        onClicked: {
                            view.currentIndex = model.index;
                            /*
                            if (!model.isDir) {
                                exportPageFileNameTextField.text = fileName;
                            }
                            */
                        }

                        onDoubleClicked: {
                            view.currentIndex = model.index;

                            if (model.isDir) {
                                oExportFilesListModel.fnOpenDir(model.index);
                                exportPagePathTextField.text = oExportFilesListModel.fnGetCurrentPath();
                            } else {
                                exportPageFileNameTextField.text = fileName;
                            }

                            oExportFilesListModel.fnUpdate();
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

                    highlighted: exportPageNameFilterComboBox.highlightedIndex === index
                }
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
                        var sExtension = oFilterExtension[exportPageNameFilterComboBox.currentIndex];

                        if (exportPageFileNameTextField.text.lastIndexOf(sExtension)!=-1
                            && exportPageFileNameTextField.text.length==exportPageFileNameTextField.text.lastIndexOf(sExtension)+sExtension.length) {
                            sExtension = "";
                        }

                        console.log(oExportFilesListModel.fnGetCurrentPath(), exportPageFileNameTextField.text, sExtension);
                        oPasswordListModel.fnExport(
                            oExportFilesListModel.fnGetCurrentPath()+'/'+exportPageFileNameTextField.text+sExtension,
                            exportPageNameFilterComboBox.currentIndex
                        );

                        oExportFilesListModel.fnUpdate();

                        stackView.pop();
                    }
                }
            }
        }

    }

}
