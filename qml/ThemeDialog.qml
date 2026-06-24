import QtQuick 2.12
import QtGraphicalEffects 1.0

import com.gpbeta.private 1.0 as G

G.DialogTemplate {
    id: dialog

    messageBackground: "../Images/background/message.png"
    dialogBackground: "../Images/background/dialog.png"

    okButtonSource {
        normal: "../Images/icon/ok.png"
        hovered: "../Images/icon/ok-hovered.png"
    }

    cancelButtonSource {
        normal: "../Images/icon/cancel.png"
        hovered: "../Images/icon/cancel-hovered.png"
    }

    buttonSpacing: 110
    buttonOffset: 28

    topPadding: 74
    bottomPadding: modal ? 96 : 80

    titlePadding: 30
    titleColor: "#AA333333"
    titleGlow: "#11333333"
    titleFont {
        pixelSize: 19
        family: "SAO UI, Source Han Sans"
        weight: Font.Medium
    }

    contentItem: ThemeText {
        horizontalAlignment: Qt.AlignHCenter
        verticalAlignment: Qt.AlignVCenter
        wrapMode: Text.WordWrap
        color: "#BB333333"
        text: dialog.text
        font.pixelSize: 16

        layer {
            enabled: true
            effect: DropShadow {
                color: "#FFFFFF"
                radius: 0
                samples: 0
                verticalOffset: 1
            }
        }
    }
}
