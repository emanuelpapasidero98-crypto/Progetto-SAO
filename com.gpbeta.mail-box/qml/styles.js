.pragma library

.import QtQuick 2.12 as Q

const SAO = {
    id: 0,
    folder: "../Images/SAO/",
    font: {
        family: "SAO UI, Source Han Sans",
        body: 15,
        label: 16,
        weight: Q.Font.Medium
    },
    foreground: { normal: "#BB333333", hovered: "#CCFFFFFF", pressed: "#DDFFFFFF", panel: "#AA333333" },
    background: { normal: "#FFFFFFFF", hovered: "#CCF1AA03", pressed: "#F1AA03" },
    panel: Qt.resolvedUrl("../Images/SAO/panel.9.png"),
    collapse: 156,
    indicator: Qt.resolvedUrl("../Images/SAO/indicator.png"),
    item: {
        normal: Qt.resolvedUrl("../Images/SAO/item.png"),
        hovered: Qt.resolvedUrl("../Images/SAO/item-hovered.png"),
        pressed: Qt.resolvedUrl("../Images/SAO/item-pressed.png")
    },
    icon: {
        attachment: {
            normal: Qt.resolvedUrl("../Images/SAO/attachment.png"),
            hovered: Qt.resolvedUrl("../Images/SAO/attachment-hovered.png")
        }
    }
};

const GGO = {
    id: 1,
    folder: "../Images/GGO/",
    font: {
        family: "Source Han Sans",
        body: 14,
        label: 14,
        weight: Q.Font.Normal
    },
    foreground: { normal: "#99FFFFFF", hovered: "#99FFFFFF", pressed: "#99FFFFFF", panel: "#AAFFFFFF" },
    background: { normal: "#00000000", hovered: "#CC5384B5", pressed: "#CC4DA5FE" },
    panel: Qt.resolvedUrl("../Images/GGO/panel.9.png"),
    collapse: 126,
    menu: Qt.resolvedUrl("../Images/GGO/menu.png"),
    item: {
        normal: "",
        hovered: Qt.resolvedUrl("../Images/GGO/item-hovered.png"),
        pressed: Qt.resolvedUrl("../Images/GGO/item-pressed.png")
    },
    icon: {
        attachment: {
            normal: Qt.resolvedUrl("../Images/GGO/attachment.png")
        }
    }
};

function icon(selector, hovered) {
    return (hovered && selector.hovered) ? selector.hovered : selector.normal;
}

// function icon(style, name, hovered) {
//     return style.folder + name + (hovered ? "-hovered.png" : ".png");
// }

function image(selector, hovered, pressed) {
    return hovered ? pressed ? selector.pressed : selector.hovered : selector.normal;
}

const color = image;
