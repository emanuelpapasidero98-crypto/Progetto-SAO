import QtQuick 2.12
import QtGraphicalEffects 1.0

import NERvGear 1.0 as NVG

import com.gpbeta.common 1.0 as GP

GP.HPBarTemplate {
    spacing: -15

    GP.HPBarItemTemplate {
        id: mainItem

        readonly property int hpMax: Math.max(ctx_level, 1) * 250

        property int hpCur: progress * hpMax

        settings: ctx_mainItem

        implicitWidth: mainImage.implicitWidth
        implicitHeight: mainImage.implicitHeight

        Behavior on hpCur {
            enabled: ctx_animation

            NumberAnimation { duration: 500 }
        }

        Image {
            id: mask

            x: 78
            y: 12
            visible: false
            source: "../Images/etc/hp-bar-mask.png"
        }

        Item {
            id: mainBar
            anchors.fill: mask

            visible: false

            Image {
                x: Math.round((mainItem.progress - 1.0) * implicitWidth)
                source: mainItem.progress <= 0.25 ? "../Images/etc/hp-bar-red.png" :
                        mainItem.progress <= 0.5  ? "../Images/etc/hp-bar-yellow.png" :
                                                   "../Images/etc/hp-bar-green.png";

                Behavior on x {
                    enabled: ctx_animation

                    NumberAnimation { easing.type: Easing.OutQuart; duration: 500 }
                }
            }
        }

        OpacityMask {
            anchors.fill: mask
            source: mainBar
            maskSource: mask
        }

        ShaderEffectSource {
            anchors.fill: mainImage
            sourceItem: mainImage
            visible: mainItem.hovered || mainItem.checked
        }

        Image {
            id: mainImage
            anchors.fill: parent

            source: ctx_charging ? "../Images/etc/hp-main-ex.png" : "../Images/etc/hp-main.png"

            HPBarLabel {
                x: 37
                y: 14
                width: 40
                height: 20

                font.pixelSize: 16

                text: mainItem.settings.label ?? "Kirito"
            }

            HPBarLabel {
                x: 217
                y: 37
                width: 80
                height: 20

                text: Math.max(mainItem.hpCur, 0) + " / " + ("   " + mainItem.hpMax).substr(-5, 5)
                horizontalAlignment: Text.AlignRight
            }

            HPBarLabel {
                x: 307
                y: 37
                width: 35
                height: 20

                text: "LV:" + (ctx_level > 0 ?
                              ("   " + ctx_level).substr(-3, 3) : " --");
            }
        }

        NVG.IconSource {
            x: 0
            y: 13
            width: 22
            height: 22

            hovered: mainItem.hovered
            pressed: mainItem.checked
            configuration: mainItem.settings.icon
        }
    }

    Column {
        spacing: -3

        Repeater {
            model: ctx_extraItems

            delegate: GP.HPBarItemTemplate {
                id: extraItem

                index: model.index
                settings: modelData
                implicitWidth: extraImage.implicitWidth
                implicitHeight: extraImage.implicitHeight

                Item {
                    x: 82
                    y: 12
                    width: extraBar.implicitWidth
                    height: extraBar.implicitHeight
                    clip: true

                    Image {
                        id: extraBar

                        x: Math.round((extraItem.progress - 1.0) * implicitWidth) - 3
                        source: extraItem.progress <= 0.25 ? "../Images/etc/hp-extra-bar-red.png" :
                                extraItem.progress <= 0.5  ? "../Images/etc/hp-extra-bar-yellow.png" :
                                                             "../Images/etc/hp-extra-bar-green.png";

                        Behavior on x {
                            enabled: ctx_animation

                            NumberAnimation { easing.type: Easing.OutQuart; duration: 500 }
                        }
                    }
                }


                ShaderEffectSource {
                    anchors.fill: extraImage
                    sourceItem: extraImage
                    visible: extraItem.hovered || extraItem.checked
                }

                Image {
                    id: extraImage
                    anchors.fill: parent

                    source: "../Images/etc/hp-extra.png"

                    HPBarLabel {
                        x: 37
                        y: 10
                        width: 40
                        height: 20

                        text: extraItem.settings.label ?? ""

                        font.pixelSize: 16
                    }
                }

                NVG.IconSource {
                    x: 0
                    y: 9
                    width: 22
                    height: 22

                    hovered: extraItem.hovered
                    pressed: extraItem.checked
                    configuration: extraItem.settings.icon
                }
            }
        }
    }
}
