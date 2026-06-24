import QtQuick 2.12

import NERvGear.Preferences 1.0
import NERvGear.Templates 1.0 as T

import "impl" 1.0 as Impl

T.Value {
    id: thiz

    property var readValue
    property var readError
    property bool d_updating: false

    interval: 5000 // 5 seconds

    update.preference: PreferenceGroup {
        RadioPreferenceGroup {
            id: pDevice
            name: "device"
            label: qsTr("Device")

            Repeater {
                model: Impl.Shared.bbmDevices
                delegate: RadioPreference {
                    name: modelData.name
                    label: name
                }

                onModelChanged: Qt.callLater(function () {
                    const config = thiz.update.configuration;
                    pDevice.defaultValue = model[0]?.name;
                    pDevice.load(config?.device);
                    pDevice.triggerPreferenceEdited();
                })
            }
        }

        Component.onCompleted: if (!Impl.Shared.bbmValidateData()) Impl.Shared.bbmUpdateDevices()
    }

    update.execute: function () {
        if (thiz.d_updating)
            return;

        const config = thiz.update.configuration;

        if (!config || !config.device)
            return thiz.readError();

        if (Impl.Shared.bbmValidateData())
            return thiz.readValue(Impl.Shared.bbmDevices, config.device);

        thiz.d_updating = true;

        Impl.Shared.bbmUpdateDevices()
            .then(function (result) {
                thiz.d_updating = false;
                thiz.readValue(result, config.device);
            })
            .catch(function () {
                d_updating = false;
                thiz.readError();
            });
    }
}
