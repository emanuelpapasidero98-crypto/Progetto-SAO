import QtQuick 2.12
import QtQuick.Templates 2.12 as T
import QtQuick.Controls.Material 2.4
import QtQuick.Controls.Material.impl 2.4

import NERvGear.Controls 1.0

T.Button {
    id: control

    property bool border: false

    padding: 12
    spacing: 6

    icon.width: 18
    icon.height: 18
    icon.color: !enabled ? Material.iconDisabledColor : checked ? Material.primaryHighlightedTextColor : Material.iconColor

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)


    Material.elevation: flat ? control.down || control.hovered ? 2 : 0
                             : control.down ? 8 : 2

    contentItem: IconLabel {
        spacing: control.spacing
        mirrored: control.mirrored
        display: control.display

        icon: control.icon
        text: control.text
        font: control.font

        color: !control.enabled ? control.Material.hintTextColor :
            control.flat && control.highlighted ? control.Material.accentColor :
            control.highlighted ? control.Material.primaryHighlightedTextColor : control.Material.foreground
    }

    background: Item {
        implicitWidth: 48
        implicitHeight: control.Material.buttonHeight

        transform: Matrix4x4 {
            matrix: Qt.matrix4x4(1, -0.35, 0, height * 0.35 * 0.5,
                                 0, 1, 0, 0,
                                 0, 0, 1, 0,
                                 0, 0, 0, 1)
        }

        Rectangle {
            id: rect

            y: 6
            width: parent.width
            height: parent.height - 12
            radius: 2
            color: control.flat ? "transparent" :
                   !control.enabled ? control.Material.buttonDisabledColor :
                    control.highlighted ? control.Material.highlightedButtonColor : control.Material.buttonColor

            border.color: control.border && control.enabled ? control.Material.foreground : "transparent"

            layer.enabled: control.enabled && !control.flat
            layer.effect: ElevationEffect {
                elevation: control.Material.elevation

                // hack the layer.smooth property
                Component.onCompleted: children[0].layer.smooth = true
            }

            Rectangle {
                y: parent.height - 4
                width: parent.width
                height: 4
                radius: 2
                visible: control.checkable && (!control.highlighted || control.flat)
                color: control.checked && control.enabled ? control.Material.accentColor : control.Material.secondaryTextColor
            }

            Ripple {
                clipRadius: 2
                width: parent.width
                height: parent.height
                pressed: control.pressed
                anchor: control
                active: control.down || control.visualFocus || control.hovered
                color: control.Material.rippleColor
            }
        }
    }

}
