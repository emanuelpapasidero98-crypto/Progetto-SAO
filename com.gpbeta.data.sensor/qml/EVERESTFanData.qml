import QtQml 2.12

import "impl" 1.0 as Impl

EVERESTData {
    valueUnit: "RPM"
    valueLoad: Impl.EVEREST.loadFanValues
    valueUpdate: Impl.EVEREST.updateFanValue
    valueInitialize: Impl.EVEREST.initializeFanValue
    title: qsTr("Fan Speed Data")
}
