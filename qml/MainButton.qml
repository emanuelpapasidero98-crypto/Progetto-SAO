import QtQuick 2.12
import QtQuick.Controls 2.12

import NERvGear 1.0 as NVG
import NERvGear.Templates 1.0 as T

AbstractButton {
    id: control

    property alias iconConfiguration: iconSource.configuration

    checkable: true

    implicitWidth: implicitBackgroundWidth
    implicitHeight: implicitBackgroundHeight
    // content size 46x46
    verticalPadding: 9
    horizontalPadding: 9

    contentItem: NVG.IconSource {
        id: iconSource

        hovered: control.hovered
        pressed: control.checked || control.down

        defaultIcon {
            normal: "../Images/symbol/help.png"
            hovered: "../Images/symbol/help-hovered.png"
        }

        image.asynchronous: true
    }

    background: Image {
        source: iconSource.pressed ? "../Images/background/btn-pressed.png" :
                iconSource.hovered ? "../Images/background/btn-hovered.png" :
                                     "../Images/background/btn.png"
    }

    onPressed: NVG.SystemCall.playSound(NVG.SFX.FeedbackClick)
}
