import QtQml 2.12

import "impl" 1.0 as Impl

EVERESTTempData {
    valueLoad: Impl.AIDA64.loadTempValues
    valueUpdate: Impl.AIDA64.updateTempValue
    valueInitialize: Impl.AIDA64.initializeTempValue
    description: Impl.Shared.trUnavailable.arg("AIDA64")
}
