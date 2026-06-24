import QtQuick 2.12
import QtQuick.Controls.Material 2.4

import NERvGear.Controls 1.0

import "../Material" as C

C.TabButton {
    id: control

    icon.width: 18
    icon.height: 18

    contentItem: IconLabel {
        spacing: control.spacing
        mirrored: control.mirrored
        display: control.display

        icon: control.icon
        text: control.text
        font: control.font

        color: !control.enabled ? control.Material.hintTextColor : control.down || control.checked ? control.Material.accentColor : control.Material.foreground
    }
}
