import NERvGear.Templates 1.0 as T

T.Data {
    title: qsTr("General Data")
    description: qsTr("General Weather Data")

    StringValue {
        name: "weather"
        title: qsTr("Weather Forecast")
        setter: data => { current = data.wxPhraseLong }
    }

    TemperatureValue {
        name: "temperature"
        title: qsTr("Current Temperature")
        setter: function (data) {
            current = unitConvert(data.temperature);
            minimum = unitConvert(data.temperatureMin24Hour);
            maximum = unitConvert(data.temperatureMax24Hour);
        }
    }

    TemperatureValue {
        name: "feel-like"
        title: qsTr("Feels Like Temperature")
        setter: data => { current = unitConvert(data.temperatureFeelsLike) }
    }

    TemperatureValue {
        name: "dew-point"
        title: qsTr("Dew Point")
        minimum: -50
        maximum: 30
        setter: data => { current = unitConvert(data.temperatureDewPoint) }
    }

    WeatherValue {
        name: "humidity"
        title: qsTr("Relative Humidity")
        units: [ "%" ]
        unit: "%"
        minimum: 0
        maximum: 100
        setter: data => { current = data.relativeHumidity }
    }

    DistanceValue {
        name: "visibility"
        title: qsTr("Visibility")
        setter: data => { current = unitConvert(data.visibility) }
    }
}
