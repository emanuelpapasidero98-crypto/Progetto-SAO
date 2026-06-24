import QtQml 2.12

import "impl" 1.0 as Impl

EVERESTFanData {
    valueLoad: Impl.AIDA64.loadFanValues
    valueUpdate: Impl.AIDA64.updateFanValue
    valueInitialize: Impl.AIDA64.initializeFanValue
    description: Impl.Shared.trUnavailable.arg("AIDA64")
}
