import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

import NERvGear.Controls 1.0

ItemDelegate {
    anchors.left: parent.left
    anchors.right: parent.right

    property alias iconColor: iconRectangle.color
    property alias iconText: iconLabel.text
    property alias nameText: nameLabel.text
    property alias mailText: mailLabel.text
    property bool onlineStatus: false

    contentItem: GridLayout {
        columns: 3
        columnSpacing: 16
        rowSpacing: 0

        Rectangle {
            id: iconRectangle
            Layout.preferredWidth: 32
            Layout.preferredHeight: 32
            Layout.rowSpan: 2

            radius: width / 2

            Label {
                id: iconLabel
                anchors.centerIn: parent

                color: page.Style.dialogColor
            }
        }

        TypeLabel {
            id: nameLabel
            Layout.fillWidth: true
        }

        Rectangle {
            id: statusRectangle
            Layout.preferredWidth: 6
            Layout.preferredHeight: 6
            Layout.rowSpan: 2

            radius: width / 2
            color: page.Style.color(page.Style.Green)
            opacity: onlineStatus ? 1 : 0
        }

        TypeLabel {
            id: mailLabel
            Layout.fillWidth: true

            category: TypeLabel.Caption
            color: Style.secondaryTextColor
        }


    }
}

