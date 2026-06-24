import QtQml 2.2

import "Private/utils.js" as Utils

QtObject {
    property string title
    property string description

    default property list<Value> values

    property var list: Utils.list
    property var query: Utils.query

}
