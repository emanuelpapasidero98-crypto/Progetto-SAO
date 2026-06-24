import QtQml 2.12

import NERvGear.Templates 1.0 as T

T.Value {

    property var updateValueImpl

    interval: 1000

    update.execute: function () {
        const value = updateValueImpl();
        if (value === undefined) {
            status = T.Value.Null;
        } else {
            status = T.Value.Ready;
            current = value;
        }
    }
}
