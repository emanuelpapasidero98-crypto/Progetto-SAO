import QtQuick 2.12
import QtQuick.Controls 2.12

import NERvGear.Controls 1.0

import "styles.js" as Styles

MouseArea {
    id: optionItem

    property alias text: iconLabel.text

    default property list<Action> actions

    implicitWidth: iconLabel.implicitWidth + 32
    implicitHeight: 24

    hoverEnabled: true

    onClicked: {
        if (menu.item.showing)
            menu.item.dismiss();
        else
            menu.item.popup(optionItem);
    }

    onTextChanged: menu.item.dismiss()

    Rectangle {
        id: background
        anchors.fill: parent
        visible: optionItem.containsMouse || menu.item.showing
        color: Styles.color(mailer.style.background, true, optionItem.pressed)
    }

    Label {
        id: iconLabel
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: 16
        anchors.right: parent.right
        anchors.rightMargin: 16

        elide: Text.ElideRight
        style: Text.Outline
        styleColor: Qt.rgba(color.r, color.g, color.b, 0.125)
        color: Styles.color(mailer.style.foreground, background.visible, optionItem.pressed)
        font {
            pixelSize: mailer.style.font.label
            family: mailer.style.font.family
            weight: mailer.style.font.weight
        }
    }

    Loader {
        id: menu
        source: mailer.style.id ? "MessagePanelMenuGGO.qml" : "MessagePanelMenuSAO.qml"
    }
}
