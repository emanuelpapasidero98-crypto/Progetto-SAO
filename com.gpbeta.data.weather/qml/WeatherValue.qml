import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

import NERvGear.Preferences 1.0
import NERvGear.Templates 1.0 as T

import "impl" as Impl

T.Value {
    id: thiz

    readonly property var currentWeatherProvider: Impl.Manager.queryCurrentWeather
    readonly property var forecastHourlyProvider: Impl.Manager.queryForecastHourly

    property var setter
    property var provider: currentWeatherProvider

    interval: 60000 // 1 min
    description: qsTr("Reference: http://www.weather.com")
    unit: units.indexOf(update.unit) === -1 ? (units[0] || "") : update.unit

    update.preference: DialogPreference {
        id: rootPref
        label: qsTr("Location")

        displayValue: thiz.update.configuration ? thiz.update.configuration.address : ""

        load: function (newValue) {
            errorLabel.visible = false;
            queryField.text = "";
            radioRepeater.model = newValue ? [ newValue ] : undefined;

            if (radioRepeater.count)
                radioColumn.children[0].checked = true;
        }

        save: function () {
            return radioGroup.checkedButton ? radioGroup.checkedButton.location : undefined;
        }

        function searchLocation() {
            if (!queryField.text)
                return;

            rootPref.enabled = false;
            errorLabel.visible = false;
            busyIndicator.running = true;

            Impl.Manager.searchLocation(queryField.text)
                .then(function (result) {
                    radioRepeater.model = result;
                    if (radioRepeater.count)
                        radioColumn.children[0].checked = true;
                }, function (err) {
                    console.warn(err);
                    errorLabel.visible = true;
                    radioRepeater.model = undefined;
                })
                .then(function () {
                    rootPref.enabled = true;
                    busyIndicator.running = false;
                });
        }

        RowLayout {
            TextField {
                id: queryField
                Layout.fillWidth: true

                placeholderText: qsTr("Search: country, city, district...")

                onAccepted: searchLocation()
            }

            ToolButton {
                icon.name: "regular:\uf002"

                onClicked: searchLocation()
            }
        }

        Item {
            implicitWidth:  Math.max(busyIndicator.implicitWidth,  radioColumn.implicitWidth)
            implicitHeight: Math.max(busyIndicator.implicitHeight, radioColumn.implicitHeight)

            BusyIndicator {
                id: busyIndicator
                anchors.centerIn: parent
                running: false
            }

            Label {
                id: errorLabel
                anchors.centerIn: parent
                enabled: false
                visible: false
                text: qsTr("Location not found")
            }

            ButtonGroup {
                id: radioGroup
                buttons: radioColumn.children
            }

            Column {
                id: radioColumn
                width: parent.width

                Repeater {
                    id: radioRepeater

                    RadioButton {
                        readonly property var location: modelData

                        text: modelData.address
                        width: radioColumn.width
                    }
                }
            }
        }
    }

    update.execute: function () {
        const config = thiz.update.configuration;

        if (!config || !config.geocode) {
            thiz.status = T.Value.Null;
            return;
        }

        if (thiz.status !== T.Value.Ready)
            thiz.status = T.Value.Loading;

        thiz.provider(config.geocode)
            .then(function (result) {
                thiz.setter(result);
                thiz.status = T.Value.Ready;
            })
            .catch(function (err) {
                console.warn(err);
                thiz.status = T.Value.Error;
            });
    }
}

