import NERvGear.Templates 1.0 as T

T.Data {
    title: qsTr("Wind Data")
    description: qsTr("Wind Speed and Direction Data")

    StringValue {
        name: "direction"
        title: qsTr("Wind Direction")
        setter: data => { current = data.windDirectionCardinal }
    }

    WeatherValue {
        name: "degree"
        title: qsTr("Wind Degrees")
        units: [ "°" ]
        unit: "°"
        minimum: 0
        maximum: 360
        setter: data => { current = data.windDirection }
    }

    SpeedValue {
        name: "speed"
        title: qsTr("Wind Speed")
        setter: data => { current = unitConvert(data.windSpeed) }
    }

    SpeedValue {
        name: "gust"
        title: qsTr("Wind Gust")
        setter: data => { current = unitConvert(data.windGust || 0) }
    }

}
