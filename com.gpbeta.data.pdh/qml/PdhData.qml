import QtQuick 2.12
import QtQuick.Controls 2.12

import NERvGear.Templates 1.0 as T
import NERvGear.Preferences 1.0
import "impl" 1.0 as PDH

T.Data {
    id: root

    title: qsTr("PDH Data")
    description: qsTr("Windows Performance Counter Data")

    T.Value {
        id: vCounter

        name: "counter"
        title: qsTr("Performance Counter")
        interval: 1000

        minimum: d.config.minimum
        maximum: d.config.maximum

        update.execute: function () {
            if (d.path) {
                current = d.convert(d.collect());
                status = T.Value.Ready;
                return;
            }
            status = T.Value.Error;
        }

        update.preference: PreferenceGroup {
            id: rootPref

            TextFieldPreference {
                id: pPath
                name: "path"
                label: qsTr("Query Path")

                rightPadding: 48

                ToolButton {
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom

                    icon.name: "regular:\uf002"

                    onClicked: {
                        const path = d.browse();
                        if (path) {
                            pPath.value = path;
                            pPath.triggerPreferenceEdited();
                        }
                    }
                }
            }

            SelectPreference {
                name: "type"
                label: qsTr("Data Type")
                defaultValue: 0
                model: [ qsTr("Decimal"), qsTr("Integer") ]
            }

            ValueRangePreference { passthrough: true }

            SelectPreference {
                name: "convert"
                label: qsTr("Unit Conversion")
                defaultValue: 0
                model: [ qsTr("None"),
                    "B\t>\tKiB", "B\t>\tMiB", "B\t>\tGiB", "B\t>\tTiB",
                    "B\t>\tKB", "B\t>\tMB", "B\t>\tGB", "B\t>\tTB",
                    "Sec\t>\tMin", "Sec\t>\tHour", "Sec\t>\tDay",
                    "K\t>\t℃", "K\t>\t℉", "℃\t>\t℉", "℉\t>\t℃",
                ]
            }

            Button {
                flat: true
                text: qsTr("Examples")
                onClicked: exampleMenu.popup()
            }

            Menu {
                id: exampleMenu
                bottomMargin: 32

                MenuItem {
                    text: qsTr("CPU Usage")
                    onClicked: {
                        rootPref.load({
                                          path: "\\Processor Information(_Total)\\% Processor Utility",
                                          type: 1,
                                          minimum: 0,
                                          maximum: 100
                                      });
                        rootPref.triggerPreferenceEdited();
                    }
                }

                MenuItem {
                    text: qsTr("GPU Usage")
                    onClicked: {
                        rootPref.load({
                                          path: "\\GPU Engine(*)\\Utilization Percentage",
                                          minimum: 0,
                                          maximum: 100
                                      });
                        rootPref.triggerPreferenceEdited();
                    }
                }
            }
        }

        readonly property var d: PDH.Counter {
            id: d

            readonly property var config: (vCounter.update.configuration instanceof Object) ?
                                           vCounter.update.configuration : {}

            readonly property var collect: config.type ? collectLong : collectDouble

            readonly property var convertors: [
                (v) => v,
                (v) => v / 1000,
                (v) => v / 1000 / 1000,
                (v) => v / 1000 / 1000 / 1000,
                (v) => v / 1000 / 1000 / 1000 / 1000,
                (v) => v / 1024,
                (v) => v / 1024 / 1024,
                (v) => v / 1024 / 1024 / 1024,
                (v) => v / 1024 / 1024 / 1024 / 1024,
                (v) => v / 60,
                (v) => v / 60 / 60,
                (v) => v / 60 / 60 / 24,
                (v) => v - 273.15,
                (v) => v * 1.8 - 459.67,
                (v) => v * 1.8 + 32,
                (v) => (v - 32) / 1.8
            ]

            readonly property var convert: convertors[config.convert] || convertors[0]

            path: config.path || ""
        }

    }

}
