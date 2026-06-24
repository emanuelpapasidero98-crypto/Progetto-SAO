import NERvGear 1.0 as NVG
import NERvGear.Preferences 1.0
import NERvGear.Templates 1.0 as T

import "../impl" 1.0 as Impl

T.Action {
    id: thiz

    readonly property var _actions: [
        { command: "pause", label: qsTr("Play / Pause"), execute: Impl.MediaControl.playPause },
        { command: "stop", label: qsTr("Stop"), execute: Impl.MediaControl.stop },
        { command: "next", label: qsTr("Next Track"), execute: Impl.MediaControl.nextTrack },
        { command: "prev", label: qsTr("Previous Track"), execute: Impl.MediaControl.previousTrack },
        { command: "vol+", label: qsTr("Volume Up"), execute: Impl.MediaControl.volumeUp },
        { command: "vol-", label: qsTr("Volume Down"), execute: Impl.MediaControl.volumeDown },
        { command: "mute", label: qsTr("Mute"), execute: Impl.MediaControl.volumeMute }
    ]

    title: qsTr("System Media Control")
    description: qsTr("System media control actions")

    execute: function () {
        return new Promise(function (resolve, reject) {
            let action;
            let command;
            if (configuration) {
                command = configuration;
                action = _actions.find(item => item.command === command);
            }
            if (action) {
                if (action.execute())
                    return resolve();
            } else { console.warn("invalid command:", command) }
            reject();
        });
    }

    preference: SelectCommandPreference {
        model: _actions
    }
}
