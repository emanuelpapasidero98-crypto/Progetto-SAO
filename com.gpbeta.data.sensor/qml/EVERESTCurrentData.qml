import QtQml 2.12

import "impl" 1.0 as Impl

EVERESTData {
    valueUnit: "A"
    valueLoad: Impl.EVEREST.loadCurrentValues
    valueUpdate: Impl.EVEREST.updateCurrentValue
    valueInitialize: Impl.EVEREST.initializeCurrentValue
    title: qsTr("Ammeter Data")
}
