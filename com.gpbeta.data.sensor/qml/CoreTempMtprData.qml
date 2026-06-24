import QtQuick 2.12

import NERvGear.Templates 1.0 as T
import NERvGear.Preferences 1.0

import "impl" 1.0 as Impl

IndexedValueData {
    id: root

    title: qsTr("CPU Multiplier")
    description: Impl.Shared.trUnavailable.arg("Core Temp")

    valueLoad: Impl.CoreTemp.loadMtprValues
    valueComponent: IndexedValue {
        title: "Core #" + index
        unit: "X"
        units: [ unit ]

        updateValueImpl: Impl.CoreTemp.updateMtprValue
        initializeValue: function () {
            const value = initData || Impl.CoreTemp.updateMtprValue(index);
            if (value !== undefined) {
                current = value;

                status = T.Value.Ready;
                initData = null;

                update.execute = updateValue;
                update.preference = Impl.Shared.rangePreference;
                update.configurationChanged.connect(updateRange);
                updateRange();
            }
        }
    }
}
