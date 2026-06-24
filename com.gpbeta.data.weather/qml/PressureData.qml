import NERvGear.Templates 1.0 as T

T.Data {
    title: qsTr("Pressure Data")
    description: qsTr("Atmospheric Pressure Data")

    StringValue {
        name: "trend"
        title: qsTr("Pressure Trend")
        setter: data => { current = data.pressureTendencyTrend }
    }

    BarValue {
        name: "bar"
        title: qsTr("Barometric Pressure")
        setter: data => { current = unitConvert(data.pressureAltimeter) }
    }

}
