import QtQuick 2.12
import QtQuick.Controls 2.12

import NERvGear 1.0 as NVG
import NERvGear.Templates 1.0 as T
import NERvExtras 1.0

import "shared.js" as Shared
import "action"

T.Widget {
    id: widget

    title: qsTr("Gallery Widget")
    solid: true
    editing: dialog.active

    implicitWidth: 128
    implicitHeight: 128

    menu: Menu {
        MenuItem {
            text: qsTr("Settings...")
            onTriggered: dialog.active = true
        }
        MenuItem {
            text: qsTr("Refresh Gallery")
            onTriggered: refreshGallery()
        }
    }

    action: GalleryWidgetAction {}

    readonly property string transitionType: settings.transition ?? "random"

    readonly property var imageUrls: {
        galleryfreshHelper;

        const path = widget.settings.imageFolder;
        if (!path)
            return [ "../Images/gallery-widget.png",
                     "../Images/image-widget.png",
                     "../Images/video-widget.png" ];

        const qDir = QtDir.construct();
        const basePath = NVG.Url.toLocalFile(Qt.resolvedUrl(path)); // handle UNC paths
        const baseUrl = (basePath.startsWith('/') ? "file://" : "file:///") + basePath;
        qDir.setPath(basePath);
        const entries = qDir.entryList(["*.jpg", "*.jpeg", "*.png", "*.webp"],
                                      QtDir.Files | QtDir.NoDotAndDotDot);
        return entries.map(function (entry) {
            return baseUrl + '/' + entry;
        });
    }

    readonly property var sampleSize: {
        if (frame.sizing)
            return undefined;

        const size = Math.max(shaderEffect.width, shaderEffect.height);
        return Qt.size(size, size);
    }

    readonly property Image fromImage: Image {
        fillMode: Image.PreserveAspectCrop
        sourceSize: sampleSize
        asynchronous: true
    }

    readonly property Image toImage: Image {
        fillMode: Image.PreserveAspectCrop
        sourceSize: sampleSize
        asynchronous: true
    }

    property bool playing: true
    property var imageFiles: []
    property int currentIndex: 0

    property bool galleryfreshHelper

    function startImageTransition() {
        const fromS = shaderEffect._fromS;
        shaderEffect._fromS = shaderEffect._toS;
        shaderEffect._toS = fromS;
        shaderEffect.progress = 0;

        if (imageFiles.length)
            fromS.source = imageFiles[currentIndex];
        else
            fromS.source = "";

        if (transitionType === "random")
            shaderEffect._transition = Math.floor(Math.random() * Shared.gl_transitions_count);

        if (fromS.status === Image.Loading)
            imageLoadConnections.target = fromS;
        else
            aniTransition.start();
    }

    function showNextImage() {
        if (++currentIndex >= imageFiles.length) currentIndex = 0;

        startImageTransition();
    }

    function showPrevImage() {
        if (--currentIndex < 0) currentIndex = imageFiles.length - 1;

        startImageTransition();
    }

    function playSlideshow() {
        playing = true;

        if (aniTransition.running)
            return;

        showNextImage();
    }

    function stopSlideshow() {
        playing = false;
        currentIndex = 0;

        if (aniTransition.running) {
            shaderEffect.progress = 1.0;
            aniTransition.stop();
        }
    }

    function toggleSlideshow() {
        if (aniTransition.running) {
            shaderEffect.progress = 1.0;
            aniTransition.stop();
            playing = false;
        } else {
            playing = true;
            showNextImage();
        }
    }

    function rollImage(forward) {
        if (imageFiles.length < 2)
            return;

        if (aniTransition.running) {
            shaderEffect.progress = 1.0;
            aniTransition.stop();
        }

        if (forward)
            showNextImage();
        else
            showPrevImage();
    }

    function refreshGallery() {
        galleryfreshHelper = !galleryfreshHelper;
    }

    onImageUrlsChanged: {
        if (aniTransition.running) {
            shaderEffect.progress = 1.0;
            aniTransition.stop();
        }

        if (widget.settings.shuffle) {
            // shuffle array elements
            imageFiles = imageUrls.slice();
            for (let i = imageFiles.length - 1; i > 0; --i) {
                const j = Math.floor(Math.random() * (i + 1));
                const temp = imageFiles[i];
                imageFiles[i] = imageFiles[j];
                imageFiles[j] = temp;
            }
        } else {
            imageFiles = imageUrls;
        }

        currentIndex = 0;
        startImageTransition();
    }

    Connections {
        id: imageLoadConnections
        enabled: widget.NVG.View.exposed
        ignoreUnknownSignals: true
        onStatusChanged: {
            if (target.status === Image.Ready || target.status === Image.Error)
                aniTransition.start();
        }
    }

    SequentialAnimation {
        id: aniTransition
        running: imageLoadConnections.enabled

        onFinished: {
            if (!widget.playing || imageFiles.length < 2)
                return;
            showNextImage();
        }

        NumberAnimation {
            target: shaderEffect
            property: "progress"
            duration: widget.settings.animateTime ?? 1000
            from: 0
            to: 1
        }

        PauseAnimation { duration: widget.settings.stillTime ?? 5000 }
    }

    MouseArea {
        anchors.fill: parent

        onClicked: {
            if (widget.settings.action) {
                actionSource.trigger(this);
                return;
            }

            toggleSlideshow();
        }

        onWheel: rollImage(wheel.angleDelta.y < 0)

        Rectangle {
            anchors {
                fill: parent
                leftMargin: frameBackground.leftPadding
                rightMargin: frameBackground.rightPadding
                topMargin: frameBackground.topPadding
                bottomMargin: frameBackground.bottomPadding
            }

            color: widget.settings.fillColor ?? "transparent"

            ShaderEffect {
                id: shaderEffect
                anchors.fill: parent

                property Image _fromS: fromImage
                readonly property real _fromR: _fromS.implicitWidth / _fromS.implicitHeight

                property Image _toS: toImage
                readonly property real _toR: _toS.implicitWidth / _toS.implicitHeight

                property int _transition: 0

                property real progress: 0
                property real ratio: width / height

                fragmentShader: Shared.generateShader(transitionType, widget.settings.fillMode === 1)
            }
        }

        NVG.BackgroundSource {
            id: frameBackground
            anchors.fill: parent
            configuration: widget.settings.frame
            z: (widget.settings.framePosition ?? true) ? 1 : -1
        }
    }

    NVG.ActionSource {
        id: actionSource
        configuration: widget.settings.action
    }

    Loader {
        id: dialog
        active: false
        sourceComponent: GalleryDialog {
            onClosing: dialog.active = false
        }
    }
}
