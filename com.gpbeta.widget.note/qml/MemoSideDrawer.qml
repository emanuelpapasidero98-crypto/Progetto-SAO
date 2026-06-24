pragma Singleton

import QtQuick 2.12
import QtQuick.Controls 2.12

import NERvGear.Controls 1.0

Drawer {
    id: drawer

    property QtObject widget
    property Rectangle base

    edge: Qt.RightEdge
    y: base ? base.y : 0
    width: Math.max(base?.width * 0.618, 128)
    height: base?.height
    dragMargin: 0
    modal: false

    ListView {
        id: listView
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.bottom: newNoteButton.top

        clip: true

        model: widget?.notes
        delegate: ItemDelegate {
            width: listView.width
            text: modelData.label
            highlighted: widget.currentIndex === index
            rightPadding: 64

            onClicked: widget.settings.current = index

            Rectangle {
                anchors.right: parent.right
                anchors.rightMargin: 12
                anchors.verticalCenter: parent.verticalCenter

                width: 20
                height: 20
                radius: 10
                color: widget.settings.notes.get(index)?.color ?? "transparent"
                border {
                    width: 1
                    color: drawer.Style.dropShadowColor
                }
            }
        }
    }

    NoteButton {
        id: newNoteButton
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        icon.name: "normal:\uf067"
        onClicked: drawer.close(widget.newNote())
    }

    NoteButton {
        id: removeNoteButton
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        highlighted: true
        enabled: widget?.notes.count > 1
        icon.name: "normal:\uf2ed"
        onClicked: widget.removeNote()
    }
}
