import QtQuick 2.12

import NERvGear 1.0 as NVG

Item {

    property NVG.SettingsMap settings
    property Component preference

    property Item contentParent: this
    property var contentTransform

    property var extraTransform // deprecated, should always apply to parent
    property var extraZ // -1000 ~ 1000, undefined

    // private

    anchors.fill: parent
}
