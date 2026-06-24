import QtQuick 2.12

import NERvGear 1.0 as NVG
import NERvGear.Controls 1.0
import NERvGear.Preferences 1.0 as P

import com.gpbeta.common 1.0

HUDElementTemplate {
    id:  thiz

    title: qsTr("Note")
    implicitWidth: 128
    implicitHeight: 128

    preference: P.ObjectPreferenceGroup {
        defaultValue: thiz.settings
        syncProperties: true

        P.TextAreaPreference {
            name: "text"
            label: qsTr("Text")
        }

        P.SelectPreference {
            name: "format"
            label: qsTr("Text Format")
            defaultValue: 0
            model: [ qsTr("Plain Text"), qsTr("Rich Text") ]
            onPreferenceEdited: Qt.callLater(function () {
                // force reload text
                const text = thiz.settings.text;
                thiz.settings.text = "";
                thiz.settings.text = text;
            })
        }

        P.FontPreference {
            name: "font"
            label: qsTr("Font")
            defaultValue: ctx_widget.defaultFont
        }

        NoDefaultColorPreference {
            name: "color"
            label: qsTr("Color")
            defaultValue: ctx_widget.defaultTextColor
        }
    }

    NoteControl {
        anchors.fill: parent
        font: thiz.settings.font ? Qt.font(thiz.settings.font) : ctx_widget.defaultFont
        textEdit {
            text: thiz.settings.text ?? ""
            textFormat: thiz.settings.format ? TextEdit.RichText : TextEdit.PlainText
            color: thiz.settings.color ?? ctx_widget.defaultTextColor
            onActiveFocusChanged: {
                if (!textEdit.activeFocus) {
                    if (checkModified())
                        thiz.settings.text = extractText(); // reset modified
                }
            }
        }

        Style.theme: {
            const brightness = textEdit.color.r * 0.375 +
                               textEdit.color.g * 0.5 +
                               textEdit.color.b * 0.125;
            return brightness < 0.5 ? Style.Light : Style.Dark;
        }
    }
}
