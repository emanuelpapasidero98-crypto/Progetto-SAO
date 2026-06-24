import QtQuick 2.12
import QtQuick.Controls 2.12

import NERvGear.Templates 1.0 as T
import NERvGear.Templates.impl 1.0 as Impl

Impl.Widget {
    id: root

//    enum Origin {
//        TopLeft     = 0,
//        TopRight    = 1,
//        BottomRight = 2,
//        BottomLeft  = 3,
//        Center      = 4
//    }

//    property int coordinateOrigin: TopLeft
    // property real x: 0
    // property real y: 0

    property string title

    property bool solid: true
    property bool resizable: true
    property bool movable: true
    property bool editing: false

    property T.Action action
    property Menu menu: Menu { enabled: false }

    signal flushSettings
    signal geometryReset
    signal widgetAdded
    signal widgetRemoved

    property var importData: ()=>{}
    property var exportData: ()=>{}
}
