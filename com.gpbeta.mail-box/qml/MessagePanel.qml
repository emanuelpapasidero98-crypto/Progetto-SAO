import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.0

import NERvGear 1.0 as NVG

Window {
    id: messagePanel

    color: "transparent"
    flags: Qt.FramelessWindowHint | Qt.Dialog | Qt.WindowStaysOnTopHint
    width: background.implicitWidth
    height: background.implicitHeight

    function showMessage(message) {
        messageView.message = message;
        messageOption.text = "From " + message.from.name;
        contentItem.state = "OPENING";
    }

    function dismiss() {
        messagePanel.contentItem.state = "CLOSING";
        NVG.SystemCall.playSound(NVG.SFX.DismissMessage);
    }

    contentItem.transitions: [
        Transition {
            to: "OPENING"
            // TODO: add BackgroundSource borders?
            PropertyAction { target: background; property: "height"; value: mailer.style.collapse }
            PropertyAction { target: messagePanel; property: "screen"; value: null }
            PropertyAction { target: messagePanel; property: "visible"; value: true }
            PropertyAction { target: messageView; property: "opacity"; value: 0 }

            NumberAnimation { target: bgTransform; property: "xScale"; from: 0.1; to: 1; duration: 200; easing.type: Easing.OutQuart }
            SequentialAnimation {
                NumberAnimation { target: background; property: "opacity"; from: 0; to: 1; duration: 250 }
                ScriptAction { script: NVG.SystemCall.playSound(NVG.SFX.PopupMessage) }
                NumberAnimation { target: background; property: "height"; to: background.implicitHeight; duration: 250; easing.type: Easing.OutQuart }
                NumberAnimation { target: messageView; property: "opacity"; from: 0; to: 1; duration: 250 }
            }
        },
        Transition {
            to: "CLOSING"
            NumberAnimation { target: bgTransform; property: "xScale"; from: 1; to: 0.1; duration: 250; easing.type: Easing.OutQuart }
            SequentialAnimation {
                NumberAnimation { target: background; property: "opacity"; from: 1; to: 0; duration: 250 }
                // TODO: SFX: dialog dismiss
                ScriptAction { script: messagePanel.close() }
            }
        }
    ]

    NVG.BackgroundSource {
        id: background
        anchors.centerIn: parent

        source: mailer.style.panel

        transform: Scale {
            id: bgTransform
            origin {
                x: background.implicitWidth / 2
                y: background.implicitHeight / 2
            }
        }

        MessageView {
            id: messageView
            anchors.fill: parent
            anchors.leftMargin: background.leftPadding
            anchors.rightMargin: background.rightPadding
            anchors.topMargin: background.topPadding
            anchors.bottomMargin: background.bottomPadding

            content {
                color: mailer.style.foreground.panel

                font {
                    pixelSize: mailer.style.font.body
                    family: mailer.style.font.family
                    weight: mailer.style.font.weight
                }
            }

            layer {
                enabled: true
                effect: mailer.style.id ? fxBlur : fxShadow
            }

            messagePartFilter: mailer.messageQuotePartFilter

            Component {
                id: fxBlur
                FastBlur {
                    radius: 0.25
                }
            }

            Component {
                id: fxShadow
                DropShadow {
                    color: "#FFFFFF"
                    radius: 0
                    samples: 0
                    verticalOffset: 1
                }
            }
        }

        MessagePanelOption {
            id: messageOption
            anchors.right: parent.right
            anchors.rightMargin: 16
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 16
            width: Math.min(implicitWidth, 320)

            Action {
                text: qsTr("Reply")
                onTriggered: {
                    mailer.markMessageAsRead(messageView.message);
                    mailer.createMessageComposer(messageView.message);
                    messagePanel.dismiss();
                }
            }

            Action {
                text: qsTr("Mark Read")
                onTriggered: {
                    mailer.markMessageAsRead(messageView.message);
                    messagePanel.dismiss();
                }
            }

            Action {
                text: qsTr("Read Later")
                onTriggered: {
                    mailer.addPendingMessage(messageView.message);
                    messagePanel.dismiss();
                }
            }

            Action {
                text: qsTr("Open HTML")
                onTriggered: messageView.viewHtml()
            }

            Action {
                text: qsTr("Ignore All")
                onTriggered: {
                    mailer.ignorePendingMessages();
                    messagePanel.dismiss();
                }
            }

        }
    }

}
