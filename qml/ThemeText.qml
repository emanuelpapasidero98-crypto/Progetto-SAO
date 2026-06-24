import QtQuick 2.12

Text {

    style: Text.Outline
    styleColor: Qt.rgba(color.r, color.g, color.b, 0.125)

    elide: Text.ElideRight
    wrapMode: Text.WrapAtWordBoundaryOrAnywhere

    font {
        family: "SAO UI, Source Han Sans"
        pixelSize: 15
        weight: Font.Medium
    }
}
