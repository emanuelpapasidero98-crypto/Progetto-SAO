import NERvGear.Templates 1.0 as T

import "impl" 1.0 as Impl

IndexedValueData {
    id: root

    title: qsTr("GPU Information Data")
    description: Impl.Shared.trUnavailable.arg("GPU-Z")

    valueLoad: Impl.GPUZ.loadInfoValues
    valueComponent: IndexedValue {

        interval: 0

        updateValueImpl: Impl.GPUZ.updateInfoValue
        initializeValue: function () {
            const record = initData || Impl.GPUZ.initializeInfoValue(index);
            if (record !== undefined) {
                title = record.title;
                current = record.value;

                status = T.Value.Ready;
                initData = null;

                update.execute = updateValue;
            }
        }
    }
}
