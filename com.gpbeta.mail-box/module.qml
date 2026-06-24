import QtQml 2.12
import NERvGear 1.0 as NVG

import "qml/impl" 1.0 as Impl

NVG.Module {
    id: module

    readonly property QtObject settings: {
        const map = NVG.Settings.load(name, "settings");
        if (map instanceof NVG.SettingsMap)
            return map;
        return  NVG.Settings.createMap(module);
    }

    initialize: function () {
        Impl.Server.enabled = true;
        if (Impl.Server.available) {
            const component = Qt.createComponent("qml/Mailer.qml");
            if (component.status === Component.Ready) {
                Impl.Server.mailer = component.createObject(module);
                return true;
            } else { console.warn(component.errorString()); }
        }
    }

    ready: function () {
        Impl.Server.mailer.startup();
    }

    cleanup: function () {
        if (NVG.Settings.isModified(settings))
            NVG.Settings.save(settings, name, "settings");
    }

}
