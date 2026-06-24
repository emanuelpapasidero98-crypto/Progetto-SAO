import QtQuick 2.12

import NERvGear 1.0 as NVG
import NERvGear.Templates 1.0 as T
import NERvGear.Preferences 1.0 as P

T.Launcher {
    id: launcher

    property int displayTopMargin
    property int displayBottomMargin
    property int displayLeftMargin
    property int displayRightMargin

    property int menuAlignHeight
    property int menuMouseOffset

    property int leftEdge: 0
    property int rightEdge: 0

    NumberAnimation {
        id: aniLauncherOffset
        target: launcher.view
        property: "x"
        duration: 400
        easing.type: Easing.InOutQuad
    }

    function updateLeftEdge(left) {
        const minLeft = launcher.geometry.left;
        const maxRight = launcher.geometry.right;
        let offsetX = 0;

        if (left < minLeft) {
            offsetX = minLeft - left;
        } else if (left > minLeft && rightEdge > maxRight) {
            // some free left spaces
            offsetX = Math.max(minLeft - left, maxRight - rightEdge);
        }

        leftEdge = left + offsetX;
        rightEdge += offsetX;

        if (offsetX) {
            aniLauncherOffset.stop();
            aniLauncherOffset.to += offsetX;
            aniLauncherOffset.start();
        }
    }

    function updateRightEdge(right) {
        const minLeft = launcher.geometry.left;
        const maxRight = launcher.geometry.right;
        let offsetX = 0;

        if (right > maxRight) {
            offsetX = maxRight - right;
        } else if (leftEdge < minLeft && right < maxRight) {
            // some free right spaces
            offsetX = Math.min(minLeft - leftEdge, maxRight - right);
        }

        leftEdge += offsetX;
        rightEdge = right + offsetX;
        if (offsetX) {
            aniLauncherOffset.stop();
            aniLauncherOffset.to += offsetX;
            aniLauncherOffset.start();
        }
    }

    function updateMenuPosition(alignment, mouse) {
        const minX = launcher.geometry.left   + displayLeftMargin;
        const minY = launcher.geometry.top    + displayTopMargin;
        const maxX = launcher.geometry.right  - displayRightMargin;
        const maxY = launcher.geometry.bottom - displayBottomMargin;

        let x;
        let y;

        if (alignment) {
            if (alignment & Qt.AlignLeft) {
                x = minX;
            } else if (alignment & Qt.AlignHCenter) {
                x = launcher.geometry.left + launcher.geometry.width / 2;
            } else if (alignment & Qt.AlignRight) {
                x = maxX;
            } // else: unsupported alignment
            y = launcher.geometry.top + (launcher.geometry.height - menuAlignHeight) / 2;
        }

        if (x === undefined) {
            x = mouse.x - menuMouseOffset;
            y = mouse.y - 150;
            if (x < minX) { x = minX } else if (x > maxX) { x = maxX }
            if (y < minY) { y = minY } else if (y > maxY) { y = maxY }
        }

        launcher.view.x = x;
        launcher.view.y = y;
    }

    onAboutToShow: {
        updateMenuPosition(alignment, mouse);
        aniLauncherOffset.stop();
        aniLauncherOffset.to = launcher.view.x;
        leftEdge = launcher.view.x;
        rightEdge = launcher.view.x + launcher.view.width;
    }

    onAboutToHide: {
        aniLauncherOffset.stop();
        aniLauncherOffset.to = launcher.view.x - 500;
        aniLauncherOffset.start();
    }
}
