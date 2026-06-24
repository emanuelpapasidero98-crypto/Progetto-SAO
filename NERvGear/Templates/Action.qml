import QtQuick 2.12

import "Private/utils.js" as Utils

QtObject {
    property string title
    property string description
    property string label: title

    property bool enabled: true
    property var shortcut

    property var environment
    property var configuration
    property Component preference // Preference component

    property var execute: Utils.execute

}
