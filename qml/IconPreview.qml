import QtQuick 2.12

import NERvGear 1.0 as NVG
import NERvGear.Templates 1.0 as T

import "utils.js" as Utils

T.Preview {
    id: preivew

    readonly property alias background: backgroundSource
    readonly property alias icon: iconSource

    implicitWidth: background.implicitWidth
    implicitHeight: background.implicitHeight

    MouseArea {
        id: mouseArea
        anchors.fill: parent

        hoverEnabled: true

        NVG.BackgroundSource {
            id: backgroundSource
            anchors.centerIn: parent
            hovered: mouseArea.containsMouse
            pressed: mouseArea.pressed
        }

        NVG.IconSource {
            id: iconSource
            anchors.centerIn: parent
            hovered: mouseArea.containsMouse
            pressed: mouseArea.pressed
            configuration: preivew.configuration
        }
    }
}
