pragma Singleton

import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12

import NERvGear.Controls 1.0

Drawer {
    id: drawer

    readonly property var memoPalette: [
        { labelColor: "#FFE66E", baseColor: "#FFF7D1" },
        { labelColor: "#A1EF9B", baseColor: "#E4F9E0" },
        { labelColor: "#FFAFDF", baseColor: "#FFE4F1" },
        { labelColor: "#D7AFFF", baseColor: "#F2E6FF" },
        { labelColor: "#9EDFFF", baseColor: "#E2F1FF" },
        { labelColor: "#E0E0E0", baseColor: "#F3F2F1" },
        { labelColor: "#767676", baseColor: "#696969" }
    ]

    property QtObject widget
    property Rectangle base

    edge: Qt.TopEdge
    height: 100
    x: base ? base.x : 0
    width: base?.width
    dragMargin: 0
    modal: false

    RowLayout {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: moreButton.top

        spacing: 0

        Repeater {
            model: memoPalette
            delegate: Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: modelData.labelColor

                MouseArea {
                    anchors.fill: parent
                    onClicked: widget.currentNote.color = modelData.baseColor
                }
            }
        }
    }

    NoteButton {
        id: moreButton
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        icon.name: "normal:\uf013"
        onClicked: drawer.close(widget.showOptions())
    }

    NoteButton {
        id: switchButton
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        icon.name: "normal:\uf070"
        highlighted: !base?.color.a
        onClicked: widget.currentNote.color = Qt.rgba(base.color.r,
                                                      base.color.g,
                                                      base.color.b,
                                                      base.color.a ? 0 : 1).toString();
    }
}
