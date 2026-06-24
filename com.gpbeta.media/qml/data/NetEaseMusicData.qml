import QtQml 2.12

import NERvGear.Templates 1.0 as T

import "../impl" 1.0 as Impl

T.Data {
    id: root

    title: qsTr("NetEase Cloud Music")
    description: qsTr("NetEase Cloud Music Player data")

    StringValue {
        name: "title"
        title: qsTr("Title")
        updateValueImpl: Impl.NetEaseMusic.queryTitle
    }

    StringValue {
        name: "artist"
        title: qsTr("Artist")
        updateValueImpl: Impl.NetEaseMusic.queryArtist
    }

    FormatStringValue {
        name: "custom"
        updateValueImpl: Impl.NetEaseMusic.queryFormat
    }
}
