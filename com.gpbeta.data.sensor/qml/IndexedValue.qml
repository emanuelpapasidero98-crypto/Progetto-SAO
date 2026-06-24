import QtQml 2.12

import NERvGear.Templates 1.0 as T

T.Value {
    interval: 1000
    status: T.Value.Null
    title: "Value #" + index

    update.execute: initializeValue

    property int index: -1
    property var initData
    property var initializeValue
    property var updateValueImpl
    property var updateValueParam: index
    property var resetValue: function () {}

    function updateValue() {
        const value = updateValueImpl(updateValueParam);
        if (value === undefined) {
            status = T.Value.Null;
            resetValue();
        } else {
            status = T.Value.Ready;
            current = value;
        }
    }

    function updateValueEx() {
        const record = updateValueImpl(updateValueParam);
        if (record === undefined) {
            status = T.Value.Null;
            resetValue();
        } else {
            status = T.Value.Ready;
            current = record.current;
            minimum = record.minimum;
            maximum = record.maximum;
        }
    }

    function updateRange() {
        const config = update.configuration;
        if (config instanceof Object) {
            minimum = config.minimum;
            maximum = config.maximum;
        } else {
            minimum = undefined;
            maximum = undefined;
        }
    }

    Component.onCompleted: initializeValue()
}
