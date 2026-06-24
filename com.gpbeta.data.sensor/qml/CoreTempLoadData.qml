import QtQuick 2.12

import NERvGear.Templates 1.0 as T
import NERvGear.Preferences 1.0

import "impl" 1.0 as Impl

IndexedValueData {
    id: root

    title: qsTr("CPU Load")
    description: Impl.Shared.trUnavailable.arg("Core Temp")

    valueLoad: Impl.CoreTemp.loadLoadValues
    valueComponent: IndexedValue {
        minimum: 0
        maximum: 100
        unit: "%"
        units: [ unit ]
        title: "Core #" + index

        updateValueImpl: Impl.CoreTemp.updateLoadValue
        initializeValue: function () {
            const value = initData || Impl.CoreTemp.updateLoadValue(index);
            if (value !== undefined) {
                current = value;

                status = T.Value.Ready;
                initData = null;

                update.execute = updateValue;
            }
        }
    }
}
