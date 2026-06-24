import QtQuick 2.12
import QtQuick.Controls 2.12

import NERvGear 1.0 as NVG
import NERvGear.Controls 1.0
import NERvGear.Preferences 1.0 as P

import "shared.js" as Shared

NVG.Window {
    id: dialog

    title: widget.title
    visible: true
    minimumWidth: 360
    minimumHeight: 580
    transientParent: widget.NVG.View.window

    onClosing: titleBar.forceActiveFocus()

    Page {
        anchors.fill: parent

        header: TitleBar { id: titleBar; text: dialog.title }

        Column {
            id: preferenceLayout
            anchors.fill: parent
            anchors.leftMargin: 16
            anchors.rightMargin: 16

            P.ObjectPreferenceGroup {
                width: parent.width
                label: qsTr("Gallery Settings")
                defaultValue: widget.settings
                syncProperties: true

                P.FolderPreference {
                    name: "imageFolder"
                    label: qsTr("Image Folder")
                }

                P.SelectPreference {
                    name: "fillMode"
                    label: qsTr("Fill Mode")
                    model: [ qsTr("Crop"), qsTr("Fit") ]
                    defaultValue: 0
                }

                P.ColorPreference {
                    name: "fillColor"
                    label: qsTr("Background Color")
                    defaultValue: "transparent"
                }

                P.BackgroundPreference {
                    name: "frame"
                    label: qsTr("Frame")

                    preferableFilter: NVG.ResourceFilter {
                        packagePattern: /com.gpbeta.media/
                    }
                }

                P.SwitchPreference {
                    name: "framePosition"
                    label: qsTr("Frame Above Image")
                    defaultValue: true
                }

                P.SwitchPreference {
                    name: "shuffle"
                    label: qsTr("Shuffle Playback")
                    defaultValue: false

                    onPreferenceEdited: Qt.callLater(widget.imageUrlsChanged)
                }

                P.SelectPreference {
                    name: "transition"
                    label: qsTr("Transition Animation")
                    defaultValue: 0
                    textRole: "label"

                    model: {
                        const array = [ { label: qsTr("Random"), source: "random" } ];
                        for (const entry in Shared.gl_transitions) // label removes ".glsl"
                            array.push({ label: entry.slice(0, -5), source: entry });
                        return array;
                    }

                    load: function (newValue) {
                        if (newValue === undefined) {
                            value = defaultValue;
                            return;
                        }

                        let index = defaultValue;
                        for (let i = 0; i < model.length; ++i) {
                            const item = model[i];
                            if (item.source === newValue) {
                                index = i;
                                break;
                            }
                        }
                        value = index;
                    }
                    save: function () {
                        return model[value].source;
                    }

                    onPreferenceEdited: Qt.callLater(aniTransition.restart)
                }

                P.SelectPreference {
                    name: "animateTime"
                    label: qsTr("Animation Speed")
                    model: [ qsTr("Fast"), qsTr("Normal"), qsTr("Slow") ]
                    defaultValue: 1

                    load: function (newValue) {
                        if (newValue === undefined) {
                            value = defaultValue;
                            return;
                        }
                        // remap times
                        if (newValue <= 500)
                            value = 0;
                        else if (newValue <= 1000)
                            value = 1;
                        else
                            value = 2;
                    }
                    save: function () {
                        switch (value) {
                        case 0: return 500;
                        case 1: return 1000;
                        case 2: return 2000;
                        default: break;
                        }
                    }

                    onPreferenceEdited: Qt.callLater(aniTransition.restart)
                }

                P.SelectPreference {
                    name: "stillTime"
                    label: qsTr("Change Image Every")
                    model: [
                        "1 " + qsTr("Second"),
                        "5 " + qsTr("Seconds"),
                        "15 " + qsTr("Seconds"),
                        "30 " + qsTr("Seconds"),
                        "1 " + qsTr("Minute"),
                        "5 " + qsTr("Minutes"),
                        "15 " + qsTr("Minutes"),
                        "30 " + qsTr("Minutes"),
                        "1 " + qsTr("Hour")
                    ]
                    defaultValue: 1

                    load: function (newValue) {
                        if (newValue === undefined) {
                            value = defaultValue;
                            return;
                        }
                        // remap times
                        if (newValue <= 1000)
                            value = 0;
                        else if (newValue <= 1000 * 5)
                            value = 1;
                        else if (newValue <= 1000 * 15)
                            value = 2;
                        else if (newValue <= 1000 * 30)
                            value = 3;
                        else if (newValue <= 60000)
                            value = 4;
                        else if (newValue <= 60000 * 5)
                            value = 5;
                        else if (newValue <= 60000 * 15)
                            value = 6;
                        else if (newValue <= 60000 * 30)
                            value = 7;
                        else
                            value = 8;
                    }
                    save: function () {
                        switch (value) {
                        case 0: return 1000;
                        case 1: return 1000 * 5;
                        case 2: return 1000 * 15;
                        case 3: return 1000 * 30;
                        case 4: return 60000;
                        case 5: return 60000 * 5;
                        case 6: return 60000 * 15;
                        case 7: return 60000 * 30;
                        case 8: return 60000 * 60;
                        default: break;
                        }
                    }

                    onPreferenceEdited: Qt.callLater(aniTransition.restart)
                }

                P.ActionPreference {
                    name: "action"
                    label: qsTr("Action")
                    message: value ? "" : qsTr("Defaults to toggle slideshow")
                }
            }
        }
    }
}
