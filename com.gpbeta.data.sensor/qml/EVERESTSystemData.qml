import QtQml 2.12

import "impl" 1.0 as Impl

EVERESTData {
    valueLoad: Impl.EVEREST.loadSystemValues
    valueUpdate: Impl.EVEREST.updateSystemValue
    valueInitialize: Impl.EVEREST.initializeSystemValue
    title: qsTr("System Data")
}
