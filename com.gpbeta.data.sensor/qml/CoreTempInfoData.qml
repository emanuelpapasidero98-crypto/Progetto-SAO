import QtQml 2.12

import NERvGear.Templates 1.0 as T

import "impl" 1.0 as Impl

T.Data {
    id: root

    title: qsTr("Processor Information")
    description: Impl.Shared.trUnavailable.arg("Core Temp")

    CoreTempInfoValue {
        title: qsTr("Model")
        name: "model"
        interval: 0
        updateValueImpl: Impl.CoreTemp.updateInfoModel
    }

    CoreTempInfoValue {
        title: qsTr("CPU Speed")
        name: "cpu-speed"
        unit: "MHz"
        units: [ unit ]
        updateValueImpl: Impl.CoreTemp.updateInfoCpuSpeed
    }

    CoreTempInfoValue {
        title: qsTr("Bus Speed")
        name: "bus-speed"
        unit: "MHz"
        units: [ unit ]
        updateValueImpl: Impl.CoreTemp.updateInfoBusSpeed
    }

    CoreTempInfoValue {
        title: qsTr("Multiplier")
        name: "multiplier"
        unit: "X"
        units: [ unit ]
        updateValueImpl: Impl.CoreTemp.updateInfoMultiplier
    }

    CoreTempInfoValue {
        title: qsTr("VID")
        name: "vid"
        unit: "V"
        units: [ unit ]
        updateValueImpl: Impl.CoreTemp.updateInfoVid
    }
}
