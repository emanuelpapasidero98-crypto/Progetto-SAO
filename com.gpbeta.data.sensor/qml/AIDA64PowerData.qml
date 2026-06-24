import QtQml 2.12

import "impl" 1.0 as Impl

EVERESTPowerData {
    valueLoad: Impl.AIDA64.loadPowerValues
    valueUpdate: Impl.AIDA64.updatePowerValue
    valueInitialize: Impl.AIDA64.initializePowerValue
    description: Impl.Shared.trUnavailable.arg("AIDA64")
}
