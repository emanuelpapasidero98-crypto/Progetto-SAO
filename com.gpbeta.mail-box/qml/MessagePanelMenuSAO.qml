import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.12

import "styles.js" as Styles

MessagePanelMenu {
    id: window

    width: itemColumn.implicitWidth
    height: itemColumn.implicitHeight + indicatorImage.height

    showAnimation: ParallelAnimation {
        NumberAnimation { target: itemColumn; property: "y"; from: indicatorImage.height; to: 0; duration: 300; easing.type: Easing.OutQuart }
        NumberAnimation { target: itemColumn; property: "opacity"; from: 0; to: 1; duration: 250 }
        NumberAnimation { target: indicatorImage; property: "x"; from: -indicatorImage.width; to: 0; duration: 300; easing.type: Easing.OutQuart }
        NumberAnimation { target: indicatorImage; property: "opacity"; from: 0; to: 1; duration: 300 }
    }

    hideAnimation: SequentialAnimation {
        ParallelAnimation {
            NumberAnimation { target: itemColumn; property: "opacity"; from: 1; to: 0; duration: 250 }
            NumberAnimation { target: indicatorImage; property: "opacity"; from: 1; to: 0; duration: 300 }
        }

        ScriptAction { script: window.hide() }
    }

    Column {
        id: itemColumn

        spacing: -3

        Repeater {
            model: optionItem.actions
            delegate: Image {
                source: Styles.image(mailer.style.item, itemArea.containsMouse, itemArea.pressed)

                MouseArea {
                    id: itemArea
                    anchors.fill: parent

                    hoverEnabled: true

                    onClicked: {
                        modelData.trigger(itemArea);
                        window.dismiss();
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

    Image {
        id: indicatorImage
        anchors.bottom: parent.bottom
        source: mailer.style.indicator
    }
}
