import QtQuick 2.12
import QtQuick.Controls 2.12

import NERvGear 1.0 as NVG
import NERvGear.Templates 1.0 as T

AbstractButton {
    id: control

    property alias iconConfiguration: iconSource.configuration
    property var defaultIcon // required

    checkable: true

    implicitWidth: implicitBackgroundWidth
    implicitHeight: implicitBackgroundHeight
    leftPadding: 35
    rightPadding: 16

    contentItem: Item {

        NVG.IconSource {
            id: iconSource
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left

            hovered: control.hovered
            pressed: control.checked || control.down

            width: 26
            height: 26

            defaultIcon {
                normal: control.defaultIcon.normal
                hovered: control.defaultIcon.hovered
            }

            image {
                asynchronous: true
                sourceSize: Qt.size(26, 26) // shell icon size hint
                fillMode: Image.Pad
            }
        }

        ThemeText {
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: iconSource.right
            anchors.leftMargin: 9
            anchors.right: parent.right

            text: control.text
            color: iconSource.pressed || iconSource.hovered ? "#EEFFFFFF" : "#CC333333"

            verticalAlignment: Text.AlignVCenter
            lineHeightMode: Text.FixedHeight
            lineHeight: 16
            maximumLineCount: 2
        }
    }

    background: Image {
        source:    control.checked ? "../Images/background/item-selected.png" :
                iconSource.pressed ? "../Images/background/item-pressed.png" :
                iconSource.hovered ? "../Images/background/item-hovered.png" :
                                     "../Images/background/item.png"
    }

    onPressed: NVG.SystemCall.playSound(NVG.SFX.FeedbackClick)
}
