import NERvGear 1.0 as NVG
import NERvGear.Preferences 1.0
import NERvGear.Templates 1.0 as T

import "../impl" 1.0 as Impl

T.Action {
    id: thiz

    readonly property var _actions: [
        { command: "pause", label: qsTr("Play / Pause"), execute: Impl.CADPlayer.playPause },
        { command: "play", label: qsTr("Play"), execute: Impl.CADPlayer.play },
        { command: "stop", label: qsTr("Stop"), execute: Impl.CADPlayer.stop },
        { command: "next", label: qsTr("Next Track"), execute: Impl.CADPlayer.nextTrack },
        { command: "prev", label: qsTr("Previous Track"), execute: Impl.CADPlayer.previousTrack },
        { command: "vol+", label: qsTr("Volume Up"), execute: Impl.CADPlayer.volumeUp },
        { command: "vol-", label: qsTr("Volume Down"), execute: Impl.CADPlayer.volumeDown },
        { command: "mute", label: qsTr("Mute"), execute: Impl.CADPlayer.volumeMute }
    ]

    title: qsTr("CAD Compatible Player")
    description: qsTr("CD Art Display compatible player actions.
Foobar 2000 with foo_cad_plus component required:
https://github.com/RangerCD/foo-cad-plus/releases")

    execute: function () {
        return new Promise(function (resolve, reject) {
            let action;
            let command;
            if (configuration) {
                command = configuration.command;
                action = _actions.find(item => item.command === command);
            }
            if (action) {
                if (action.execute())
                    return resolve();
            } else { console.warn("invalid command:", command) }
            reject();
        });
    }

    preference: PreferenceGroup {
        SelectCommandPreference {
            model: _actions
        }
    }
}
