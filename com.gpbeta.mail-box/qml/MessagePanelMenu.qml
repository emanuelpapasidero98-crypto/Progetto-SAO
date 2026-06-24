import QtQuick 2.12
import QtQuick.Window 2.12

import NERvGear 1.0 as NVG

Window {
    id: window

    readonly property bool showing: visible && !hideAnimation.running

    property Animation showAnimation
    property Animation hideAnimation

    color: "transparent"
    flags: Qt.FramelessWindowHint | Qt.Tool

    function popup(item) {
        if (showing)
            return;

        const pos = item.mapToGlobal((item.width - width) / 2, -height);
        x = pos.x;
        y = pos.y;
        visible = true;
        requestActivate();
        hideAnimation.stop();
        showAnimation.start();

        NVG.SystemCall.playSound(NVG.SFX.PopupMenu);
    }

    function dismiss() {
        if (!showing)
            return;
        showAnimation.stop();
        hideAnimation.start();
    }
}
