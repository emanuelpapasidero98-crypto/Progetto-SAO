import QtQml 2.3
import NERvGear.Templates 1.0 as T
import NERvGear.Preferences 1.0
import "impl" 1.0 as WMI

T.Data {
    id: root

    title: qsTr("WMI Data")
    description: qsTr("Windows Management Instrumentation Data")

    T.Value {
        id: vQuery

        name: "query"
        title: qsTr("WQL Query")
        interval: 1000

        update.execute: function () {
            if (d.config.query) {
                if (d.services.query(d.config.query)) {
                    status = T.Value.Loading;
                    return;
                }
            }
            status = T.Value.Error;
        }

        update.preference: PreferenceGroup {
            TextFieldPreference {
                name: "source"
                label: qsTr("Network Resource")
                hint: "ROOT\\CIMV2"
            }
            TextFieldPreference {
                name: "query"
                label: qsTr("WQL Query String")
                hint: "SELECT Name FROM Win32_Processor"
            }
            TextAreaPreference {
                name: "script"
                label: qsTr("Output Script")
                hint: "this.current = objects[0].Name"
                error: {
                    const err = d.scriptError;

                    if (!err)
                        return "";

                    if (err instanceof SyntaxError)
                        return err.toString();

                    return err.name + " @" + (err.lineNumber - 2) + ": " + err.message;
                }
            }
        }

        readonly property var d: QtObject {
            id: d

            readonly property var config: (vQuery.update.configuration instanceof Object) ?
                                           vQuery.update.configuration : {}

            readonly property var script: evalScript(config.script)

            property var scriptError: null

            property QtObject services: WMI.Services {

                source: d.config.source || ""

                onQueryResult: {
                    if (success) {
                        try {
                            vQuery.status = T.Value.Ready;
                            d.script.call(vQuery, objects);
                            return;
                        } catch (err) {
                            d.scriptError = err;
                        }
                    }
                    vQuery.status = T.Value.Error;
                }
            }

            function evalScript(script) {
                scriptError = null;

                if (!script)
                    return defaultScript;

                try {
                    return Function("objects", "'use strict';\n" + script);
                } catch (err) {
                    scriptError = err;
                }

                vQuery.current = undefined;

                return nullScript;
            }

            function defaultScript(objects) {
                const object = objects[0];
                if (object) {
                    for (const name in object) {
                        vQuery.current = object[name];
                        return;
                    }
                }
                vQuery.current = undefined;
            }

            function nullScript() {
            }
        }

    }

}
