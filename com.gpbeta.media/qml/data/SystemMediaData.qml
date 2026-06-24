import QtQml 2.12

import NERvGear.Templates 1.0 as T

import "../impl" 1.0 as Impl

T.Data {
    id: root

    title: qsTr("System Media Data")
    description: qsTr("SMTC system media control data, available on Windows 10 and above.")

    StringValue {
        name: "title"
        title: qsTr("Title")
        updateValueImpl: Impl.MediaControl.queryTitle
    }

    StringValue {
        name: "artist"
        title: qsTr("Artist")
        updateValueImpl: Impl.MediaControl.queryArtist
    }

    StringValue {
        name: "album"
        title: qsTr("Album")
        updateValueImpl: Impl.MediaControl.queryAlbum
    }

    StringValue {
        name: "player"
        title: qsTr("Player Name")
        updateValueImpl: Impl.MediaControl.queryPlayer
    }

    CommonValue {
        name: "state"
        title: qsTr("Playback State")
        updateValueImpl: Impl.MediaControl.queryState

        current: 0
        minimum: 0
        maximum: 2
    }

    T.Value {
        name: "time"
        title: qsTr("Playback Time")

        interval: 1000
        current: "0:00"
        minimum: "0:00"
        maximum: "0:00"

        update.execute: function () {
            const value = Impl.MediaControl.queryTimeText();
            if (value === undefined) {
                status = T.Value.Null;
            } else {
                status = T.Value.Ready;
                current = value.current;
                maximum = value.maximum;
            }
        }
    }

    T.Value {
        name: "progress"
        title: qsTr("Playback Progress")

        interval: 1000
        current: 0
        minimum: 0
        maximum: 1

        update.execute: function () {
            const value = Impl.MediaControl.queryTime();
            if (value === undefined) {
                status = T.Value.Null;
            } else {
                status = T.Value.Ready;
                current = value.current;
                maximum = value.maximum;
            }
        }
    }

    StringValue {
        name: "cover"
        title: qsTr("Cover Image")
        updateValueImpl: Impl.MediaControl.queryCover
    }

    FormatStringValue {
        name: "custom"
        updateValueImpl: Impl.MediaControl.queryFormat
        formatMessage: qsTr("Available Fields") + ": %title%, %artist%, %album%, %state%, %time%, %time_s%, %length%, %length_s%"
    }
}
