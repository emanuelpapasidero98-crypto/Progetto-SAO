import QtQml 2.12

import "impl" 1.0 as Impl

EVERESTData {
    valueUnit: "V"
    valueLoad: Impl.EVEREST.loadVoltValues
    valueUpdate: Impl.EVEREST.updateVoltValue
    valueInitialize: Impl.EVEREST.initializeVoltValue
    title: qsTr("Voltage Data")
}
