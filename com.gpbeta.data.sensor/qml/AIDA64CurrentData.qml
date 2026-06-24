import QtQml 2.12

import "impl" 1.0 as Impl

EVERESTCurrentData {
    valueLoad: Impl.AIDA64.loadCurrentValues
    valueUpdate: Impl.AIDA64.updateCurrentValue
    valueInitialize: Impl.AIDA64.initializeCurrentValue
    description: Impl.Shared.trUnavailable.arg("AIDA64")
}
