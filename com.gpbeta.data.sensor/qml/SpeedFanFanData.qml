import QtQml 2.12

import NERvGear.Templates 1.0 as T

import "impl" 1.0 as Impl

SpeedFanData {
    id: root

    title: qsTr("Fan Speed Data")

    valueTitle: "Fan #"
    valueUnit: "RPM"
    valueLoad: Impl.SpeedFan.loadFanValues
    valueUpdate: Impl.SpeedFan.updateFanValue
}
