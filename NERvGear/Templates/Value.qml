import QtQml 2.2

import "Private" as Private

QtObject {
    id: thiz

    enum Status {
        Null = 0,
        Ready = 1,
        Loading = 2,
        Error = 3
    }

    property string name

    property string title
    property string description

    property var units: []
    property string unit

    property int interval: 0 // ms
    property int status: Value.Null

    property var current
    property var maximum
    property var minimum

    property var environment

    readonly property ValueUpdateGroup update: ValueUpdateGroup {}
//    readonly property Action action: Action {}

}
