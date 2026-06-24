import QtQuick 2.12
import QtQuick.Controls 2.12

import NERvGear 1.0 as NVG
import NERvGear.Controls 1.0
import NERvGear.Templates 1.0 as T

import "."

T.Widget {
    id: widget

    readonly property var initialFont: ({ family: "Source Han Sans SC", pixelSize: 15 })
    readonly property font defaultFont: Qt.font(settings.font ?? initialFont)

    readonly property color transparentColor: "transparent"
    readonly property color defaultTextColor: settings.foreground ?? noteControl.Style.primaryTextColor

    readonly property NVG.SettingsList notes: NVG.Settings.makeList(settings, "notes")
    readonly property int currentIndex: settings.current ?? 0
    // capture notes.count in binding to force currentNote update when adding or removing
    readonly property var currentNote: notes.get(Math.min(currentIndex, notes.count - 1))

    title: qsTr("Memo Widget")
    solid: true
    resizable: true
    editing: dialog.item?.visible ?? false

    implicitWidth: 200
    implicitHeight: 200

    menu: Menu {
        Action {
            text: qsTr("Settings...")
            onTriggered: showOptions()
        }
    }

    onNotesChanged: {
        if (notes.count < 1) {
            const map = NVG.Settings.createMap(notes);
            map.label = "Memo 1";
            map.color = MemoTopDrawer.memoPalette[0].baseColor;
            notes.append(map);
        }
    }

    function newNote() {
        // current note should be saved due to active focus lost
        const map = NVG.Settings.createMap(notes);
        const palette = MemoTopDrawer.memoPalette;
        map.label = "Memo " + (notes.count + 1);
        map.color = palette[Math.floor(Math.random() * palette.length)].baseColor;
        notes.append(map);
        settings.current = notes.count - 1;
    }

    function removeNote(index) {
        index = index ?? currentIndex;

        if (notes.count <= 1 || index < 0 || index >= notes.count)
            return;

        // change the index only if removing last note
        if (index + 1 === notes.count)
            settings.current = index - 1;

        notes.remove(index);
    }

    function showOptions() {
        dialog.active = true;
    }

    NVG.BackgroundSource {
        id: bgSource
        anchors.fill: parent

        configuration: widget.settings.background
        defaultBackground {
            normal: "../Images/background.9.png"
        }
    }

    Rectangle {
        id: bgRect
        anchors.fill: parent
        anchors.topMargin: bgSource.topPadding
        anchors.bottomMargin: bgSource.bottomPadding
        anchors.leftMargin: bgSource.leftPadding
        anchors.rightMargin: bgSource.rightPadding

        color: currentNote?.color ?? transparentColor
        border.color: (color.a && widget.NVG.View.active) ?
                          noteControl.Style.dividerColor : transparentColor

        NoteControl {
            id: noteControl
            anchors.fill: parent

            font: currentNote?.font ? Qt.font(currentNote.font) : widget.defaultFont
            topPadding: 32

            textEdit {
                text: currentNote?.text ?? ""
                color: currentNote?.foreground ?? widget.defaultTextColor
                antialiasingMode: (bgRect.color.a === 1 && textEdit.color.a === 1) ? -1 : 0
                onActiveFocusChanged: {
                    if (!textEdit.activeFocus) {
                        if (checkModified())
                            currentNote.text = extractText(); // reset modified
                    }
                }
            }

            Style.theme: {
                const brightness = bgRect.color.r * 0.375 +
                                   bgRect.color.g * 0.5 +
                                   bgRect.color.b * 0.125;
                return brightness < 0.5 ? Style.Dark : Style.Light;
            }

            TextInput {
                id: titleInput
                anchors.left: parent.left
                anchors.leftMargin: 8
                anchors.top: parent.top
                anchors.right: actionRow.visible ? actionRow.left : parent.right
                anchors.rightMargin: 8

                height: 32
                topPadding: 4
                selectByMouse: true
                clip: true
                enabled: !widget.editing
                text: currentNote?.label ?? ""
                color: noteControl.textEdit.color
                selectionColor: noteControl.textEdit.selectionColor
                selectedTextColor: noteControl.textEdit.selectedTextColor
                antialiasingMode: noteControl.textEdit.antialiasingMode
                font {
                    family: noteControl.font.family
                    pixelSize: 15
                }

                onActiveFocusChanged: if (!activeFocus) currentNote.label = text
                onEditingFinished: focus = false
                Keys.onEscapePressed: focus = false
            }

            Row {
                id: actionRow
                anchors.top: parent.top
                anchors.right: parent.right
                anchors.rightMargin: 4

                visible: widget.NVG.View.active

                NoteButton {
                    icon.name: "light:\uf103"
                    width: 34
                    height: 32
                    topPadding: 8
                    enabled: !widget.editing
                    onClicked: {
                        MemoTopDrawer.base = bgRect;
                        MemoTopDrawer.widget = widget;
                        MemoTopDrawer.parent = bgSource;
                        MemoTopDrawer.open();
                    }
                }

                NoteButton {
                    icon.name: "light:\uf03a"
                    width: 34
                    height: 32
                    topPadding: 8
                    onClicked: {
                        MemoSideDrawer.base = bgRect;
                        MemoSideDrawer.widget = widget;
                        MemoSideDrawer.parent = bgSource;
                        MemoSideDrawer.open();
                    }
                }
            }
        }
    }

    Loader {
        id: dialog
        active: false
        sourceComponent: EditDialog {
            onClosing: dialog.active = false
        }
    }
}
