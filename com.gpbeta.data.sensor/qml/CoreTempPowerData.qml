import QtQuick 2.12

import NERvGear.Templates 1.0 as T
import NERvGear.Preferences 1.0

import "impl" 1.0 as Impl

IndexedValueData {
    id: root

    title: qsTr("CPU Power")
    description: Impl.Shared.trUnavailable.arg("Core Temp")

    valueLoad: Impl.CoreTemp.loadPowerValues
    valueComponent: IndexedValue {
        title: "CPU #" + index
        unit: "W"
        units: [ unit ]
        minimum: 0

        updateValueImpl: Impl.CoreTemp.updatePowerValue
        initializeValue: function () {
            const record = initData || Impl.CoreTemp.initializePowerValue(index);
            if (record !== undefined) {
                current = record.current;
                maximum = record.maximum;

                status = T.Value.Ready;
                initData = null;

                update.execute = updateValue;
            }
        }
    }
}
