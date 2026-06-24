
WeatherValue {
    units: [ "km", "mi" ]

    current: 0
    minimum: 0
    maximum: 50 * _ratio

    property real _ratio: unit === "mi" ? 0.621 : 1

    function unitConvert(si) {
        return si * _ratio;
    }

}
