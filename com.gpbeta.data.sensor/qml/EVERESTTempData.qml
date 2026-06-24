import QtQml 2.12

import "impl" 1.0 as Impl

EVERESTData {
    valueUnit: "°C"
    valueLoad: Impl.EVEREST.loadTempValues
    valueUpdate: Impl.EVEREST.updateTempValue
    valueInitialize: Impl.EVEREST.initializeTempValue
    title: qsTr("Temperature Data")
}
