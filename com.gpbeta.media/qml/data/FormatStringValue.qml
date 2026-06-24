import QtQml 2.12

import NERvGear.Templates 1.0 as T
import NERvGear.Preferences 1.0

StringValue {
    id: thiz

    property string formatMessage

    title: qsTr("Custom Text")

    updateValueParam: update.configuration || "%title% - %artist%"

    update.preference: TextFieldPreference {
        label: qsTr("Format String")
        hint: "%title% - %artist%"
        message: thiz.formatMessage
    }
}
