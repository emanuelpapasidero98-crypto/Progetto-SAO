import QtQuick 2.12
import QtQuick.Controls 2.12

import NERvGear 1.0 as NVG
import NERvGear.Controls 1.0
import NERvGear.Preferences 1.0 as P

NVG.Window {
    id: dialog

    title: widget.title
    visible: true
    minimumWidth: 360
    minimumHeight: 580
    transientParent: widget.NVG.View.window

    onClosing: titleBar.forceActiveFocus()

    Page {
        anchors.fill: parent

        header: TitleBar { id: titleBar; text: dialog.title }

        Column {
            id: preferenceLayout
            anchors.fill: parent
            anchors.leftMargin: 16
            anchors.rightMargin: 16

            P.ObjectPreferenceGroup {
                width: parent.width
                label: qsTr("Widget Settings")
                defaultValue: widget.settings
                syncProperties: true

                P.BackgroundPreference {
                    name: "background"
                    label: qsTr("Background")
                    defaultBackground: bgSource.defaultBackground
                }

                P.FontPreference {
                    name: "font"
                    label: qsTr("Default Text Font")
                    defaultValue: Qt.font(widget.initialFont)
                }

                NoDefaultColorPreference {
                    name: "foreground"
                    label: qsTr("Default Text Color")
                    defaultValue: widget.transparentColor
                }
            }

            P.ObjectPreferenceGroup {
                width: parent.width
                label: qsTr("Memo Settings")
                defaultValue: widget.currentNote
                syncProperties: true


                P.TextFieldPreference {
                    name: "label"
                    label: qsTr("Title")
                    display: P.TextFieldPreference.ExpandLabel
                }

                P.FontPreference {
                    name: "font"
                    label: qsTr("Font")
                    defaultValue: widget.defaultFont
                    onDefaultValueChanged: if (!widget.currentNote.font) load()
                }

                NoDefaultColorPreference {
                    name: "color"
                    label: qsTr("Color")
                    defaultValue: widget.transparentColor
                }

                NoDefaultColorPreference {
                    name: "foreground"
                    label: qsTr("Text Color")
                    defaultValue: widget.defaultTextColor
                    onDefaultValueChanged: if (!widget.currentNote.foreground) load()
                }
            }
        }
    }
}
