import QtQuick 2.12

import NERvGear 1.0 as NVG

Item {
    // note that changing any private symbols in this file will affect
    // 3rd-party MOD HUD Custom widget's elements

    readonly property NVG.SettingsMap settings: NVG.Settings.makeMap(craftElement.settings, "view")
    readonly property var environment: craftElement.environment

    readonly property NVG.DataSource defaultDataSource: craftElement.defaultData
    readonly property NVG.DataSource itemDataSource: craftElement.itemData

    readonly property string defaultLabel: craftElement.defaultText
    readonly property string itemLabel: craftElement.itemSettings.label ?? ""
    readonly property string elementLabel: craftElement.settings.label ?? ""

    readonly property bool hovered: craftElement.interactionArea.containsMouse
    readonly property bool pressed: craftElement.interactionArea.pressed
    readonly property bool itemHovered: craftElement.itemBackground.hovered
    readonly property bool itemPressed: craftElement.itemBackground.pressed

    property string title

    property Component preference // NERvGear.Preferences.ObjectGroupPreference
}
