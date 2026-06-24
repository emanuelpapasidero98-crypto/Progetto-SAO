import QtQuick 2.12
import QtQuick.Controls 2.12

import "styles.js" as Styles

MessagePanelMenu {
    id: thiz

    width: backgroundImage.implicitWidth
    height: backgroundImage.implicitHeight

    showAnimation: ParallelAnimation {
        PropertyAction { target: itemColumn; property: "opacity"; value: 1 }
        PropertyAction { target: backgroundImage; property: "scale"; value: 1 }

        NumberAnimation { target: backgroundImage; property: "y"; from: 100; to: 0; duration: 300; easing.type: Easing.OutQuart }
        NumberAnimation { target: backgroundImage; property: "opacity"; from: 0; to: 1; duration: 200 }
    }

    hideAnimation: SequentialAnimation {
        ParallelAnimation {
            NumberAnimation { target: itemColumn; property: "opacity"; from: 1; to: 0; duration: 200 }
            NumberAnimation { target: backgroundImage; property: "scale"; from: 1; to: 0.1; duration: 300; easing.type: Easing.OutQuart }
            NumberAnimation { target: backgroundImage; property: "opacity"; from: 1; to: 0; duration: 300 }
        }

        ScriptAction { script: thiz.hide() }
    }

    Image {
        id: backgroundImage
        source: mailer.style.menu
        transformOrigin: Item.Bottom

        Column {
            id: itemColumn

            x: 8
            y: 8
            spacing: -4

            Repeater {
                model: optionItem.actions
                delegate: MouseArea {
                    id: itemArea

                    width: 146
                    height: 46
                    hoverEnabled: true

                    onClicked: {
                        modelData.trigger(itemArea);
                        thiz.dismiss();
                    }

                    Image {
                        anchors.fill: parent
                        source: Styles.image(mailer.style.item, itemArea.containsMouse, itemArea.pressed)
                    }

                    Label {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.left: parent.left
                        anchors.leftMargin: 15
                        anchors.right: parent.right
                        anchors.rightMargin: 15

                        text: modelData.text
                        horizontalAlignment: Text.AlignHCenter
                        style: Text.Outline
                        styleColor: Qt.rgba(color.r, color.g, color.b, 0.125)
                        color: Styles.color(mailer.style.foreground, itemArea.containsMouse, itemArea.pressed)
                        font {
                            pixelSize: mailer.style.font.label
                            family: mailer.style.font.family
                            weight: mailer.style.font.weight
                        }
                    }
                }
            }
        }
    }

}
