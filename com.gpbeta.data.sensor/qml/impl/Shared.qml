pragma Singleton

import QtQml 2.12

import NERvGear.Preferences 1.0

QtObject {
    readonly property Component rangePreference: ValueRangePreference {}

    readonly property string trUnavailable: qsTr("Data available only if %1 is running and the 'Shared Memory' function is enabled.")

    readonly property var bbmPromises: []
    property var bbmDevices: []

    function bbmValidateData() {
        return (Date.now() - (bbmDevices._timestamp ?? 0)) < 2500;
    }

    function bbmUpdateDevices() {
        return new Promise(function (resolve, reject) {
            if (bbmPromises.length) { // loading
                bbmPromises.push({ resolve: resolve, reject: reject });
                return;
            }

            bbmPromises.push({ resolve: resolve, reject: reject });

            const xhr = new XMLHttpRequest();
            xhr.responseType = 'json';
            xhr.onerror = function () {
                console.warn("cannot retrieve bluetooth battery monitor data:", xhr.status, xhr.statusText);
                bbmDevices = [];
                bbmPromises.forEach(promise => promise.reject());
                bbmPromises.length = 0;
            }
            xhr.onload = function () {
                if (xhr.status >= 200 && xhr.status < 300) {
                    bbmDevices = xhr.response.devices;
                    bbmDevices._timestamp = Date.now();

                    bbmPromises.forEach(promise => promise.resolve(bbmDevices));
                    bbmPromises.length = 0;
                } else {
                    xhr.onerror();
                }
            }
            xhr.open("GET", "http://127.0.0.1:9876/devices");
            xhr.timeout = 1000;
            xhr.send();
        });
    }
}
