
WeatherValue {
    units: [ "°C", "°F" ]

    minimum: -40
    maximum: _f ? 122 : 50

    property bool _f: unit === "°F"

    function unitConvert(si) {
        return _f ? (si * 9 / 5) + 32 : si;
    }

}
