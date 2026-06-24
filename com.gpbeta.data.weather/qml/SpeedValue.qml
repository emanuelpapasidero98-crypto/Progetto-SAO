
WeatherValue {
    units: [ "kph", "mph" ]

    current: 0
    minimum: 0
    maximum: 500 * _ratio

    property real _ratio: unit === "mph" ? 0.621 : 1

    function unitConvert(si) {
        return si * _ratio;
    }

}
