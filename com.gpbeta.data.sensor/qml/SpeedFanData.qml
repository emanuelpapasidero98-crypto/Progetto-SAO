import QtQml 2.12

import NERvGear.Templates 1.0 as T

import "impl" 1.0 as Impl

IndexedValueData {
    id: root

    property string valueTitle
    property string valueUnit
    property var valueUpdate

    description: Impl.Shared.trUnavailable.arg("SpeedFan")

    valueComponent: IndexedValue {

        title: valueTitle + index
        unit: valueUnit
        units: [ unit ]

        updateValueImpl: valueUpdate
        initializeValue: function () {
            const record = initData || valueUpdate(index);
            if (record !== undefined) {
                current = record;

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
