import QtQml 2.12


QtObject {
    property string title
    property string description
    property string label: title

    property Component preference // Preference component
    property var configuration

    property var reset: ()=>{}
    property var update: ()=>{}
    property var execute: ()=>{}
}
