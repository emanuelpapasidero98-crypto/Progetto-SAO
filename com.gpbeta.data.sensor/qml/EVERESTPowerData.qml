import QtQml 2.12

import "impl" 1.0 as Impl

EVERESTData {
    valueUnit: "W"
    valueLoad: Impl.EVEREST.loadPowerValues
    valueUpdate: Impl.EVEREST.updatePowerValue
    valueInitialize: Impl.EVEREST.initializePowerValue
    title: qsTr("Power Consumption Data")
}
