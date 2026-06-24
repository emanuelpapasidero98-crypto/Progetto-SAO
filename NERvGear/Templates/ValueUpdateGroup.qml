import QtQml 2.2
import "Private/utils.js" as Utils

QtObject {

    property Component preference // Preference component
    property var configuration
    
    property string unit

    property var execute: Utils.execute
}
