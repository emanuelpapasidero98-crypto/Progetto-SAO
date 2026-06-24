import QtQml 2.12

import NERvGear.Templates 1.0 as T

T.Data {
    id: root

    property Component valueComponent
    property var valueLoad
    property var valueType

    list: function () {
        if (values.length)
            return values;

        const objects = [];
        const records = valueLoad(valueType);

        records.forEach(function (record) {
            const props = { name: record.name, initData: record };
            objects.push(valueComponent.createObject(root, props));
        });

        values = objects; // append to values

        return values;
    }

    query: function (name) {
        return valueComponent.createObject(root, { name: name });
    }
}
