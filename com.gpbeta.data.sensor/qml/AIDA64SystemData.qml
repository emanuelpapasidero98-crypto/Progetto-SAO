import QtQml 2.12

import "impl" 1.0 as Impl

EVERESTSystemData {
    valueLoad: Impl.AIDA64.loadSystemValues
    valueUpdate: Impl.AIDA64.updateSystemValue
    valueInitialize: Impl.AIDA64.initializeSystemValue
    description: Impl.Shared.trUnavailable.arg("AIDA64")
}
