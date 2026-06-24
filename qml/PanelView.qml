import QtQuick 2.12
import QtGraphicalEffects 1.0

import NERvGear 1.0 as NVG

NVG.View {
    id: panelView

    property QtObject target

    property Item labelText
    property Item imageSource
    property Item descripText

    readonly property int collapsedHeight: 278

    z: 1
    solid: true
    color: "transparent"
    compositor: NVG.LauncherCompositor
    width: panelImage.implicitWidth
    height: panelImage.implicitHeight + shadowImage.implicitHeight

    opacity: 0
    visible: opacity > 0

    onTargetChanged: {
        if (target) {
            if (target.theme.infoPanel) {
                let newLabelText = null;
                let newImageSource = null;
                let newDescripText = null;
                if (target.label) {
                    newLabelText = cLabelText.createObject(panelImage);
                    newLabelText.text = target.label;
                }
                if (target.image) {
                    newImageSource = cImageSource.createObject(panelImage);
                    newImageSource.configuration = target.image;
                }
                if (target.text) {
                    newDescripText = cDescripText.createObject(panelImage);
                    newDescripText.text = target.text;
                }

                if (contentItem.state === "CLOSED") {
                    if (labelText) labelText.destroy();
                    if (imageSource) imageSource.destroy();
                    if (descripText) descripText.destroy();
                    defaultImageFade.enabled = false;
                    defaultImage.opacity = 0;
                    defaultImageFade.enabled = true;
                } else {
                    if (labelText) labelText.opacity = 0;
                    if (imageSource) imageSource.opacity = 0;
                    if (descripText) descripText.opacity = 0;

                    if (newLabelText) newLabelText.opacity = 1;
                    if (newImageSource) newImageSource.opacity = 1;
                    if (newDescripText) newDescripText.opacity = 1;

                    defaultImage.opacity = newImageSource ? 0 : 1;
                }
                labelText = newLabelText;
                imageSource = newImageSource;
                descripText = newDescripText;

                if (target.text) {
                    if (contentItem.state === "COLLAPSED")
                        contentItem.state = "EXPANDED";
                    else if (contentItem.state === "CLOSED")
                        contentItem.state = "COLLAPSED";
                    // else EXPANDED
                } else { contentItem.state = "COLLAPSED"; }
            } else { contentItem.state = "CLOSED"; }
        } else { contentItem.state = "CLOSED"; }
    }

    contentItem {
        state: "CLOSED"
        states: [
            State {
                name: "COLLAPSED"
                PropertyChanges { target: panelClip; width: panelImage.implicitWidth; height: collapsedHeight }
            },
            State {
                name: "EXPANDED"
                PropertyChanges { target: panelClip; height: panelImage.implicitHeight }
            }
        ]

        transitions: [
            Transition {
                from: "COLLAPSED,EXPANDED"
                to: "CLOSED"

                ScriptAction { script: launcher.updateLeftEdge(panelView.x + panelView.width) }
                NumberAnimation {
                    target: panelView
                    property: "opacity"
                    to: 0
                    duration: 250
                }
            },
            Transition {
                from: "CLOSED"
                to: "COLLAPSED"

                onRunningChanged: {
                    if (!running) {
                        // show content
                        if (labelText) labelText.opacity = 1;
                        if (descripText) descripText.opacity = 1;
                        if (imageSource)
                            imageSource.opacity = 1;
                        else
                            defaultImage.opacity = 1;

                        // expand the panel
                        if (panelView.target?.text) {
                            if (panelView.contentItem.state === "COLLAPSED")
                                panelView.contentItem.state = "EXPANDED";
                        }
                    }
                }

                ScriptAction {
                    script: {
                        launcher.updateLeftEdge(panelView.x);
                        NVG.SystemCall.playSound(NVG.SFX.PopupPanel);
                    }
                }
                NumberAnimation {
                    target: panelClip;
                    properties: "width,height"
                    from: 80
                    duration: 400
                    easing.type: Easing.OutQuart
                }
                NumberAnimation {
                    target: panelView
                    property: "opacity"
                    from: 0
                    to: 1
                    duration: 500
                }
            },
            Transition {
                NumberAnimation {
                    target: panelClip;
                    properties: "width,height"
                    duration: 250
                    easing.type: Easing.OutQuart
                }
            }
        ]
    }

    Item {
        id: panelClip

        clip: true
        x: panelImage.implicitWidth - width
        y: Math.max(collapsedHeight - height, 0)
        width: panelImage.implicitWidth
        height: panelImage.implicitHeight

        Image {
            id: panelImage
            x: -panelClip.x
            y: -panelClip.y

            source: "../Images/etc/panel.png"

            Image {
                id: defaultImage
                anchors.centerIn: parent
                anchors.horizontalCenterOffset: -10
                anchors.verticalCenterOffset: -50
                visible: opacity
                opacity: 0
                source: "../Images/icon/default.png"

                Behavior on opacity {
                    id: defaultImageFade
                    NumberAnimation { duration: 250 }
                }
            }
        }
    }

    Item {
        id: shadowClip
        anchors.left: panelClip.left
        anchors.right: panelClip.right
        anchors.top: panelClip.bottom

        clip: true
        height: shadowImage.implicitHeight

        Image {
            id: shadowImage
            x: -shadowClip.x
            source: "../Images/etc/panel-shadow.png"
        }
    }

    Component {
        id: cLabelText

        ThemeText {
            id: thiz
            anchors.left: parent.left
            anchors.leftMargin: 10
            anchors.right: parent.right
            anchors.rightMargin: 30
            anchors.top: parent.top
            anchors.topMargin: 23

            opacity: 0
            color: "#BB333333"
            horizontalAlignment: Text.AlignHCenter

            Behavior on opacity {
                NumberAnimation {
                    duration: 250
                    onRunningChanged: if (!running && !thiz.opacity) thiz.destroy()
                }
            }
        }
    }

    Component {
        id: cImageSource

        NVG.ImageSource {
            id: thiz
            anchors.centerIn: parent
            anchors.horizontalCenterOffset: -10
            anchors.verticalCenterOffset: -50

            width: Math.min(implicitWidth, 210)
            height: Math.min(implicitHeight, 210)
            opacity: 0
            fillMode: Image.PreserveAspectFit

            onSourceChanged: playing = Qt.binding(()=>panelView.exposed)

            Behavior on opacity {
                NumberAnimation {
                    duration: 250
                    onRunningChanged: if (!running && !thiz.opacity) thiz.destroy()
                }
            }
        }
    }

    Component {
        id: cDescripText

        ThemeText {
            id: thiz
            anchors.left: parent.left
            anchors.leftMargin: 20
            anchors.right: parent.right
            anchors.rightMargin: 40
            anchors.top: parent.top
            anchors.topMargin: 295

            height: 130
            opacity: 0
            color: "#BB333333"

            Behavior on opacity {
                NumberAnimation {
                    duration: 250
                    onRunningChanged: if (!running && !thiz.opacity) thiz.destroy()
                }
            }
        }
    }
}
