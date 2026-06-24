import QtQuick 2.12
import QtQuick.Controls 2.12
import QtGraphicalEffects 1.0

import NERvGear.Controls 1.0
import NERvGear.Templates 1.0 as T

T.Dialog {
    id: dialog

    property url messageBackground
    property url dialogBackground

    property alias okButtonSource: okButton.source
    property alias cancelButtonSource: cancelButton.source

    property int buttonSpacing
    property int buttonOffset

    property font titleFont
    property color titleColor
    property color titleGlow
    property int titlePadding

    implicitWidth: implicitBackgroundWidth
    implicitHeight: implicitBackgroundHeight

    leftPadding: 16
    rightPadding: 16
    margins: 0

    background: Item {
        implicitWidth: bgImage.implicitWidth
        implicitHeight: bgImage.implicitHeight

        BorderImage {
            id: bgImage
            anchors.centerIn: parent

            source: modal ? dialogBackground : messageBackground

            border {
                top: topPadding
                bottom: bottomPadding
                left: leftPadding
                right: rightPadding
            }

            Text {
                anchors.top: parent.top
                anchors.topMargin: titlePadding
                anchors.left: parent.left
                anchors.right: parent.right

                text: dialog.title
                color: dialog.titleColor
                font: dialog.titleFont
                horizontalAlignment: Qt.AlignHCenter

                layer {
                    enabled: true
                    effect: Glow {
                        color: dialog.titleGlow
                        radius: 4
                        samples: 7
                    }
                }
            }

            Row {
                anchors.bottom: parent.bottom
                anchors.bottomMargin: dialog.buttonOffset
                anchors.horizontalCenter: parent.horizontalCenter

                visible: dialog.modal
                opacity: dialog.contentItem.opacity
                spacing: buttonSpacing

                ImageButton {
                    id: okButton
                    onClicked: dialog.accept()
                }

                ImageButton {
                    id: cancelButton
                    onClicked: dialog.reject()
                }
            }
        }
    }

    enter: Transition {
        PropertyAction { property: "opacity"; value: 0 }
        PropertyAction { target: bgImage; property: "height"; value: dialog.topPadding + dialog.bottomPadding - 16 }
        PropertyAction { target: dialog.contentItem; property: "opacity"; value: 0 }

        NumberAnimation { target: dialogScale; property: "xScale"; from: 0.1; to: 1; duration: 200; easing.type: Easing.OutQuart }
        SequentialAnimation {
            NumberAnimation { property: "opacity"; from: 0; to: 1; duration: 250 }
            NumberAnimation { target: bgImage; property: "height"; to: background.implicitHeight; duration: 250; easing.type: Easing.OutQuart }
            NumberAnimation { target: dialog.contentItem; property: "opacity"; from: 0; to: 1; duration: 250 }
        }
    }

    exit: Transition {
        NumberAnimation { target: dialogScale; property: "xScale"; from: 1; to: 0.1; duration: 250; easing.type: Easing.OutQuart }
        NumberAnimation { property: "opacity"; from: 1; to: 0; duration: 250 }
    }

    // BUG: fix dialogScale cannot be referred
    readonly property Scale _dialogScale: Scale {
        id: dialogScale
        origin {
            x: dialog.background.implicitWidth / 2
            y: dialog.background.implicitHeight / 2
        }
    }

    // FIXME: hack QQuickPopupItem's transform
    Component.onCompleted: background.parent.transform = dialogScale
}
