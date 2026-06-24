
WeatherValue {
    units: [ "mb", "in" ]

    current: 0
    minimum:  960 * _ratio
    maximum: 1050 * _ratio

    readonly property real _ratio: unit === "in" ? 0.029 : 1

    function unitConvert(si) {
        return si * _ratio;
    }

}
