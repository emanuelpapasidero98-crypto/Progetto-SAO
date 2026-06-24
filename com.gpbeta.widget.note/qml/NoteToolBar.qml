pragma Singleton

import QtQml.Models 2.12
import QtQuick 2.12
import QtQuick.Controls 2.12

import NERvGear.Controls 1.0
import NERvGear.Private 1.0 as NVG

Rectangle {
    id: toolBar

    readonly property QtObject textEdit: parent?.textEdit ?? defaultTextEdit
    readonly property alias documentHandler: handler

    anchors.bottom: parent?.bottom
    anchors.bottomMargin: -height
    anchors.left: parent?.left
    anchors.right: parent?.right

    height: 40
    visible: false
    color: toolBar.Style.rippleColor

    state: textEdit.activeFocus ? "SHOW" : "HIDE"
    transitions: [
        Transition {
            to: "SHOW"
            SequentialAnimation {
                PropertyAction { target: toolBar; property: "visible"; value: true }
                NumberAnimation { target: toolBar; property: "anchors.bottomMargin"; to: 0; duration: 200; easing.type: Easing.OutQuad }
            }
        },
        Transition {
            to: "HIDE"
            SequentialAnimation {
                NumberAnimation { target: toolBar; property: "anchors.bottomMargin"; to: -toolBar.height; duration: 200; easing.type: Easing.OutQuad }
                PropertyAction { target: toolBar; property: "visible"; value: false }
            }
        }
    ]

    ListView {
        anchors.fill: parent
        orientation: ListView.Horizontal
        snapMode: ListView.SnapToItem
        model: ObjectModel {
            NoteButton {
                icon.name: "normal:\uf032"
                highlighted: handler.bold
                onClicked: handler.bold = !handler.bold
            }
            NoteButton {
                icon.name: "normal:\uf033"
                highlighted: handler.italic
                onClicked: handler.italic = !handler.italic
            }
            NoteButton {
                icon.name: "normal:\uf0cd"
                highlighted: handler.underline
                onClicked: handler.underline = !handler.underline
            }
            NoteButton {
                icon.name: "normal:\uf0cc"
                highlighted: handler.strikeout
                onClicked: handler.strikeout = !handler.strikeout
            }
            NoteButton {
                icon.name: "normal:\uf894"
                onClicked: fontLevelMenu.popup(this, 0, 0)
            }
            NoteButton {
                icon.name: "normal:\uf039"
                onClicked: textAlignMenu.popup(this, 0, 0)
            }
        }
    }

    Menu {
        id: fontLevelMenu

        width: 42
        focus: false

        Style.theme: toolBar.Style.theme

        NoteButton {
            text: "S"
            highlighted: handler.fontLevel === -1
            onClicked: fontLevelMenu.close(handler.fontLevel = -1)
        }
        NoteButton {
            text: "M"
            highlighted: handler.fontLevel === 0
            onClicked: fontLevelMenu.close(handler.fontLevel = 0)
        }
        NoteButton {
            text: "L"
            highlighted: handler.fontLevel === 1
            onClicked: fontLevelMenu.close(handler.fontLevel = 1)
        }
        NoteButton {
            text: "XL"
            highlighted: handler.fontLevel === 2
            onClicked: fontLevelMenu.close(handler.fontLevel = 2)
        }
        NoteButton {
            text: "XXL"
            highlighted: handler.fontLevel === 3
            onClicked: fontLevelMenu.close(handler.fontLevel = 3)
        }
    }

    Menu {
        id: textAlignMenu

        width: 42
        focus: false

        Style.theme: toolBar.Style.theme

        NoteButton {
            icon.name: "normal:\uf036"
            highlighted: handler.alignment === Qt.AlignLeft
            onClicked: textAlignMenu.close(handler.alignment = Qt.AlignLeft)
        }
        NoteButton {
            icon.name: "normal:\uf037"
            highlighted: handler.alignment === Qt.AlignHCenter
            onClicked: textAlignMenu.close(handler.alignment = Qt.AlignHCenter)
        }
        NoteButton {
            icon.name: "normal:\uf038"
            highlighted: handler.alignment === Qt.AlignRight
            onClicked: textAlignMenu.close(handler.alignment = Qt.AlignRight)
        }
    }

    QtObject {
        id: defaultTextEdit

        readonly property QtObject textDocument: null
        readonly property int cursorPosition: 0
        readonly property int selectionStart: 0
        readonly property int selectionEnd: 0
        readonly property bool activeFocus: false

        function forceActiveFocus() {}
        function select() {}
    }

    NVG.DocumentHandler {
        id: handler
        document: textEdit.textDocument
        cursorPosition: textEdit.cursorPosition
        selectionStart: textEdit.selectionStart
        selectionEnd: textEdit.selectionEnd
    }
}
