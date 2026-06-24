import QtQuick 2.12

import NERvGear.Templates 1.0 as T
import NERvGear.Preferences 1.0

import "impl" 1.0 as Impl

IndexedValueData {
    id: root

    title: qsTr("GPU Sensor Data")
    description: Impl.Shared.trUnavailable.arg("GPU-Z")

    valueLoad: Impl.GPUZ.loadSensorValues
    valueComponent: IndexedValue {

        updateValueImpl: Impl.GPUZ.updateSensorValue
        initializeValue: function () {
            const record = initData || Impl.GPUZ.initializeSensorValue(index);
            if (record !== undefined) {
                unit = record.unit;
                units = [ record.unit ];
                current = record.value;
                title = record.title;

                status = T.Value.Ready;
                initData = null;

                if (unit.startsWith("%")) {
                    minimum = 0;
                    maximum = 100;
                } else {
                    update.preference = Impl.Shared.rangePreference;
                    update.configurationChanged.connect(updateRange);
                    updateRange();
                }
                update.execute = updateValue;
            }
        }
    }
}
