import QtQuick 2.12
import QtQuick.Controls.Material 2.4
import QtQuick.Controls.Material.impl 2.4
import QtGraphicalEffects 1.0

import NERvGear.Controls 1.0

import "../Material" as C

C.Dialog {
    id: control

    // BUG: cannot reference Translate object by id
    readonly property Translate _footerTranslate: Translate { y: 24 }

    property alias headlines: columnHeader.children

    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             contentHeight + topPadding + bottomPadding)

    padding: 48
    // NOTE: fix Qt Dialog header layout
    topPadding: columnHeader.implicitHeight > 0 ? columnHeader.implicitHeight + 52 : 40
    bottomMargin: 32

    Material.elevation: 8

    onFooterChanged: if (footer) footer.transform = _footerTranslate

    Component.onCompleted: footerChanged()

    background: Canvas {
        readonly property bool darkTheme: control.Material.theme === control.Material.Dark
        readonly property color cBack:  darkTheme ? "#525252" : "#F6F6F6"
        readonly property color cGrey:  darkTheme ? "#4C4C4C" : "#E6E6E6"
        readonly property color cWhite: darkTheme ? "#555555" : "#FFFFFF"

        readonly property real xGrey: 0.5
        readonly property real xWhite: 0.8

        readonly property real rWhite: 0.35
        readonly property real rGrey: 1 / rWhite

        opacity: 0.95
        renderStrategy: Canvas.Cooperative
        renderTarget: Canvas.FramebufferObject

        layer.enabled: control.Material.elevation > 0
        layer.effect: ElevationEffect {
            elevation: control.Material.elevation
        }

        onPaint: {
            var bgOffset = 4;
            var bgHeight = height - bgOffset;
            var ctx = getContext("2d");
            ctx.fillStyle = cBack;
            // decoration line
            ctx.fillRect(0, 0, width, 1.4);
            // background
            ctx.fillRect(0, bgOffset, width, bgHeight);
            // grey triangle
            var posGrey = width * xGrey;
            var widthGrey = width - posGrey;
            var heightGrey = widthGrey * rGrey;
            ctx.fillStyle = cGrey;
            ctx.beginPath();
            ctx.moveTo(posGrey, height);
            if (heightGrey > bgHeight) {
                ctx.lineTo(posGrey + bgHeight / rGrey, bgOffset);
                ctx.lineTo(width, bgOffset);
            } else { // triangle
                ctx.lineTo(width, height - heightGrey);
            }
            ctx.lineTo(width, height);
            ctx.fill();
            // white triangle
            var widthWhite = width * xWhite;
            var heightWhite = widthWhite * rWhite;
            ctx.fillStyle = cWhite;
            ctx.beginPath();
            ctx.moveTo(widthWhite, height);
            if (heightWhite > bgHeight) {
                ctx.lineTo(widthWhite - bgHeight / rWhite, bgOffset);
                ctx.lineTo(0, bgOffset);
            } else { // triangle
                ctx.lineTo(0, height - heightWhite);
            }
            ctx.lineTo(0, height);
            ctx.fill();
            // header
            var lineWidth = width - leftPadding - rightPadding;
            ctx.fillStyle = control.Material.dividerColor;
            ctx.fillRect(leftPadding, topPadding - 12, lineWidth, 1);
            // footer
            ctx.fillRect(leftPadding, height - bottomPadding + 14, lineWidth, 1);
        }
    }

    footer: DialogButtonBox {
        visible: count > 0
    }

    header: Item {
        implicitWidth: Math.max(labelTitle.implicitWidth, columnHeader.implicitWidth + control.leftPadding + control.rightPadding)

        C.Label {
            id: labelTitle
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.top

            text: control.title
            visible: control.title
            elide: C.Label.ElideRight
            color: "#EEFFFFFF"
            style: Text.Outline
            styleColor: "transparent"
            font.capitalization: Font.AllUppercase
            font.weight: Font.Medium
            font.pixelSize: 30

            layer.enabled: true
            layer.effect: Glow {
                color: "#33000000"
                cached: true
                radius: 8
                spread: 0.6
                samples: 16
            }
        }

        Column {
            id: columnHeader
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.topMargin: 24
        }

        SmallButton {
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.topMargin: 8
            anchors.rightMargin: -width / 2

            visible: control.closePolicy === C.Dialog.CloseOnEscape

            icon.width: 18
            icon.height: 18
            icon.name: "regular:\uf068"

            onClicked: control.reject()
        }
    }
}
