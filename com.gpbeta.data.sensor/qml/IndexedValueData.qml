import QtQuick 2.12

import NERvGear.Templates 1.0 as T

T.Data {
    id: root

    property Component valueComponent
    property var valueLoad

    list: function () {
        if (values.length)
            return values;

        const objects = [];
        const records = valueLoad();

        for (let i = 0; i < records.length; ++i) {
            const props = { index: i, name: i, initData: records[i] };
            objects.push(valueComponent.createObject(root, props));
        }

        values = objects; // append to values

        return values;
    }

    query: function (name) {
        const index = Number(name);

        if (isNaN(index))
            return null;

        return valueComponent.createObject(root, { index: index, name: name });
    }

}
