import NERvGear.Templates 1.0 as T

T.Data {
    title: qsTr("Raw Data")
    description: qsTr("For 3rd Party Development")

    WeatherValue {
        name: "current"
        title: qsTr("Current Weather")
        unit: ""
        setter: data => { current = data }
    }

    WeatherValue {
        name: "hourly"
        title: qsTr("Hourly Forecast")
        unit: ""
        setter: data => { current = data }
        provider: forecastHourlyProvider
    }

}
