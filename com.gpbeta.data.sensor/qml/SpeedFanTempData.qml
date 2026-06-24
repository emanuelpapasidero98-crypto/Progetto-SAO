import QtQml 2.12

import NERvGear.Templates 1.0 as T

import "impl" 1.0 as Impl

SpeedFanData {
    id: root

    title: qsTr("Temperature Data")

    valueTitle: "Temp #"
    valueUnit: "C"
    valueLoad: Impl.SpeedFan.loadTempValues
    valueUpdate: Impl.SpeedFan.updateTempValue
}
