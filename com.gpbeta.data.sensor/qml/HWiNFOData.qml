import QtQml 2.12

import NERvGear.Templates 1.0 as T

import "impl" 1.0 as Impl

NamedValueData {
    id: root

    description: Impl.Shared.trUnavailable.arg("HWiNFO")

    valueLoad: Impl.HWiNFO.loadSensorValues

    valueComponent: IndexedValue {

        title: "Value #" + name

        updateValueImpl: Impl.HWiNFO.updateSensorValue
        initializeValue: function () {
            const record = initData || Impl.HWiNFO.initializeSensorValue(name);
            if (record !== undefined) {
                current = record.current;
                minimum = record.minimum;
                maximum = record.maximum;
                index = record.index;
                title = record.title;
                description = record.description;
                unit = record.unit;
                units = [ record.unit ];

                status = T.Value.Ready;
                initData = null;

                update.execute = updateValueEx;
                updateValueParam = record.param;
            }
        }
        resetValue: function () {
            update.execute = initializeValue;
        }
    }
}
