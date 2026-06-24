import QtQuick 2.12
import QtGraphicalEffects 1.0

import NERvGear 1.0 as NVG

NVG.View {
    id: indicatorView

    property QtObject target

    readonly property int minHeight: 70
    readonly property bool indicating: target && !target.currentChecked

    z: 2
    solid: true
    acceptInput: false
    color: "transparent"
    compositor: NVG.LauncherCompositor
    width: imageUpper.implicitWidth
    height: imageUpper.implicitHeight + imageLower.implicitHeight

    opacity: indicating ? 1 : 0
    visible: opacity > 0

    Behavior on opacity {
        id: bOpacity
        NumberAnimation  { duration: bOpacity.targetValue ? 250 : 200 }
    }

    BorderImage {
        id: imageUpper
        anchors.bottom: parent.verticalCenter

        source: "../Images/etc/indicator-upper.png"
        height: {
            if (indicating) {
                if (target.contentHeight > minHeight)
                    return Math.min(target.contentHeight, indicatorView.height) / 2;
            }

            return minHeight / 2;
        }

        border { top: 20; bottom: 13 }

        Behavior on height { NumberAnimation { duration: 200; easing.type: Easing.OutQuad } }
    }

    BorderImage {
        id: imageLower
        anchors.top: parent.verticalCenter

        source: "../Images/etc/indicator-lower.png"
        height: imageUpper.height

        border { top: 13; bottom: 20 }
    }
}
