import QtQml 2.12

import NERvGear.Templates 1.0 as T

import "../impl" 1.0 as Impl

T.Data {
    id: root

    title: qsTr("CAD Compatible Player")
    description: qsTr("CD Art Display compatible player data.
Foobar 2000 with foo_cad_plus component required:
https://github.com/RangerCD/foo-cad-plus/releases")

    StringValue {
        name: "title"
        title: qsTr("Title")
        updateValueImpl: Impl.CADPlayer.queryTitle
    }

    StringValue {
        name: "artist"
        title: qsTr("Artist")
        updateValueImpl: Impl.CADPlayer.queryArtist
    }

    StringValue {
        name: "album"
        title: qsTr("Album")
        updateValueImpl: Impl.CADPlayer.queryAlbum
    }

    CommonValue {
        name: "volume"
        title: qsTr("Volume")
        updateValueImpl: Impl.CADPlayer.queryVolume

        current: 0
        minimum: 0
        maximum: 100
    }

    CommonValue {
        name: "state"
        title: qsTr("Playback State")
        updateValueImpl: Impl.CADPlayer.queryState

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
            const value = Impl.CADPlayer.queryTimeText();
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
            const value = Impl.CADPlayer.queryTime();
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
        updateValueImpl: Impl.CADPlayer.queryCover
    }

    FormatStringValue {
        name: "custom"
        updateValueImpl: Impl.CADPlayer.queryFormat
        formatMessage: qsTr("Available Fields") + ": %title%, %artist%, %album%, %state%, %time%, %time_s%, %length%, %length_s%"
    }
}
