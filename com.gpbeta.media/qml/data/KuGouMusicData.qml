import QtQml 2.12

import NERvGear.Templates 1.0 as T

import "../impl" 1.0 as Impl

T.Data {
    id: root

    title: qsTr("KuGou Music")
    description: qsTr("KuGou Music Player data")

    StringValue {
        name: "title"
        title: qsTr("Title")
        updateValueImpl: Impl.KuGouMusic.queryTitle
    }
}
