import QtQuick 2.12
import QtQuick.Controls 2.12

import NERvGear 1.0 as NVG
import NERvGear.Dialogs 1.0 as D
import NERvGear.Templates 1.0 as T

T.Widget {
    id: widget

    property bool imageChanged: false

    title: NVG.Url.info(image.source).fileName

    solid: false
    editing: dialog.visible
    implicitWidth: defaultImage.implicitWidth
    implicitHeight: defaultImage.implicitHeight

    menu: Menu {
        Action {
            text: qsTr("Auto Resize")
            checkable: true
            checked: widget.settings.autoResize ?? true
            onToggled: widget.settings.autoResize = checked
        }

        Menu {
            title: qsTr("Fill Mode")

            Action {
                text: qsTr("Fit")
                checkable: true
                checked: image.fillMode === Image.PreserveAspectFit
                onTriggered: settings.fillMode = Image.PreserveAspectFit
            }

            Action {
                text: qsTr("Crop")
                checkable: true
                checked: image.fillMode === Image.PreserveAspectCrop
                onTriggered: settings.fillMode = Image.PreserveAspectCrop
            }
        }

        Action {
            text: qsTr("Reset Size")

            onTriggered: {
                if (defaultImage.visible) {
                    widget.width = defaultImage.implicitWidth;
                    widget.height = defaultImage.implicitHeight;
                } else {
                    resetWidgetSize();
                }
            }
        }

        Action {
            text: qsTr("Change Image")

            onTriggered: dialog.open()
        }
    }

    D.ImageDialog {
        id: dialog

        transientParent: widget.NVG.View.window

        onAccepted: changeImage(configuration)
    }

    DropArea {
        anchors.fill: parent

        onEntered: drag.accepted = drag.hasUrls;

        onPositionChanged: drag.action = Qt.LinkAction;

        onDropped: changeImage(drop.urls[0])

        NVG.ImageSource {
            id: image
            anchors.fill: parent

            asynchronous: true
            fillMode: settings.fillMode ?? Image.PreserveAspectFit
            configuration: widget.settings.url

            onStatusChanged: {
                if (imageChanged && status === Image.Ready) {
                    imageChanged = false;
                    autoResizeWidget();
                }
            }

            onSourceChanged: playing = true
        }

        Image {
            id: defaultImage
            anchors.centerIn: parent

            visible: image.status !== Image.Ready
            source: "../Images/image-widget.png"
        }
    }

    states: [
        State {
            when: defaultImage.visible

            PropertyChanges {
                target: widget
                explicit: true
                implicitWidth: defaultImage.implicitWidth
                implicitHeight: defaultImage.implicitHeight
            }
        },
        State {
            when: !defaultImage.visible

            PropertyChanges {
                target: widget
                explicit: true
                implicitWidth: 48
                implicitHeight: 48
            }
        }
    ]

    function resetWidgetSize() {
        // ignore @2x size
        width = image.sourceSize.width;
        height = image.sourceSize.height;
        geometryReset();
    }

    function autoResizeWidget() {
        if (settings.autoResize === false)
            return;
        resetWidgetSize();
    }

    function changeImage(url) {
        settings.url = url;
        if (image.status === Image.Ready)
            autoResizeWidget();
        else
            imageChanged = true;
    }
}
