import QtQuick 2.12
import QtQuick.Controls 2.12

import NERvGear.Controls 1.0

TextField {
    id: thiz

    property alias labelText: label.text

    topPadding: 2
    leftPadding: 64

    font.pixelSize: 13

    Label {
        id: label
        anchors.left: parent.left

        y: thiz.topPadding
        width: 56
        elide: Text.ElideRight
        color: thiz.Style.hintTextColor
        font.pixelSize: 13
    }
}
