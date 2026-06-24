import QtQml 2.12

import NERvGear.Templates 1.0 as T

import "impl" 1.0 as Impl

SpeedFanData {
    id: root

    title: qsTr("Voltage Data")

    valueTitle: "Volt #"
    valueUnit: "V"
    valueLoad: Impl.SpeedFan.loadVoltValues
    valueUpdate: Impl.SpeedFan.updateVoltValue
}
