import QtQml 2.12

import NERvGear.Templates 1.0 as T

T.Data {
    id: root

    title: qsTr("Bluetooth Monitor Data")
    description: qsTr("Data available only if Bluetooth Battery Monitor is running and the 'HTTP/JSON API' function is enabled. Usage:
https://www.bluetoothgoodies.com/info/battery-monitor-api/")

    BluetoothBatteryMonitorValue {
        id: vStatus
        name: "status"
        title: qsTr("Device Status")
        status: T.Value.Ready
        current: -1
        minimum: -1
        maximum: 1

        readError: function () { vStatus.current = -1; }
        readValue: function (devices, name) {
            const value = devices.find((object)=>object.name === name);
            if (value) {
                vStatus.current = Number(value.connected);
            } else {
                vStatus.current = -1;
            }
        }
    }

    BluetoothBatteryMonitorValue {
        id: vBattery
        name: "battery"
        title: qsTr("Battery Level")
        units: [ "%" ]
        unit: "%"
        minimum: 0
        maximum: 100

        readError: function () { vBattery.status = T.Value.Null; }
        readValue: function (devices, name) {
            const value = devices.find((object)=>object.name === name);
            if (value && value.connected) {
                vBattery.current = value.level;
                vBattery.status = T.Value.Ready;
            } else {
                vBattery.status = T.Value.Null;
            }
        }
    }

}
