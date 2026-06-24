import QtQml 2.12

import NERvGear.Templates 1.0 as T

import "../impl" 1.0 as Impl

T.Data {
    id: root

    title: qsTr("QQ Music")
    description: qsTr("QQ Music Player data")

    StringValue {
        name: "title"
        title: qsTr("Title")
        updateValueImpl: Impl.QQMusic.queryTitle
    }

    StringValue {
        name: "artist"
        title: qsTr("Artist")
        updateValueImpl: Impl.QQMusic.queryArtist
    }

    FormatStringValue {
        name: "custom"
        updateValueImpl: Impl.QQMusic.queryFormat
    }
}
