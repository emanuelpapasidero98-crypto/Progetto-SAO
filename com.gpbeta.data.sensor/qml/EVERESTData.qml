import QtQml 2.12

import NERvGear.Templates 1.0 as T

import "impl" 1.0 as Impl

NamedValueData {
    id: root

    property string valueUnit
    property var valueUpdate
    property var valueInitialize

    description: Impl.Shared.trUnavailable.arg("EVEREST")

    valueComponent: IndexedValue {

        unit: valueUnit
        units: unit ? [ unit ] : []

        updateValueImpl: valueUpdate
        initializeValue: function () {
            const record = initData || valueInitialize(name);
            if (record !== undefined) {
                index = record.index;
                title = record.title;
                current = record.value;

                status = T.Value.Ready;
                initData = null;

                if (typeof record.value === "number") {
                    update.preference = Impl.Shared.rangePreference;
                    update.configurationChanged.connect(updateRange);
                    updateRange();
                }
                update.execute = updateValue;
            }
        }
    }
}
