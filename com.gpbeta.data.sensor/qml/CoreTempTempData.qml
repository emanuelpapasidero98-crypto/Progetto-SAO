import QtQuick 2.12

import NERvGear.Templates 1.0 as T
import NERvGear.Preferences 1.0

import "impl" 1.0 as Impl

IndexedValueData {
    id: root

    title: qsTr("CPU Temperature")
    description: Impl.Shared.trUnavailable.arg("Core Temp")

    valueLoad: Impl.CoreTemp.loadTempValues
    valueComponent: IndexedValue {
        title: "Core #" + index
        minimum: 0

        updateValueImpl: Impl.CoreTemp.updateTempValue
        initializeValue: function () {
            const record = initData || Impl.CoreTemp.initializeTempValue(index);
            if (record !== undefined) {
                current = record.current;
                maximum = record.maximum;
                unit = record.celsius ? "°C" : "°F";
                units = [ unit ];

                status = T.Value.Ready;
                initData = null;

                update.execute = updateValue;
            }
        }
    }
}
