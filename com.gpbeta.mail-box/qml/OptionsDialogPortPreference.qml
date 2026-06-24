import QtQuick 2.12
import NERvGear.Preferences 1.0 as P

P.TextFieldPreference {
    display: P.TextFieldPreference.ExpandLabel
    label: qsTr("Port")
    validator: IntValidator { bottom: 1; top: 65535 }
    onInputFocusChanged: if (!inputFocus && !acceptableInput) value = defaultValue
}
