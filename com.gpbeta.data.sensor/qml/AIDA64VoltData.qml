import QtQml 2.12

import "impl" 1.0 as Impl

EVERESTVoltData {
    valueLoad: Impl.AIDA64.loadVoltValues
    valueUpdate: Impl.AIDA64.updateVoltValue
    valueInitialize: Impl.AIDA64.initializeVoltValue
    description: Impl.Shared.trUnavailable.arg("AIDA64")
}
