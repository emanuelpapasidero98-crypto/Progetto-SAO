import NERvGear.Templates 1.0 as T

T.Data {
    title: qsTr("UV Data")
    description: qsTr("Ultraviolet Radiation Data")

    StringValue {
        name: "level"
        title: qsTr("UV Level")
        setter: data => { current = data.uvDescription }
    }

    WeatherValue {
        name: "index"
        title: qsTr("UV Index")
        minimum: 0
        maximum: 11
        setter: data => { current = data.uvIndex }
    }

}
