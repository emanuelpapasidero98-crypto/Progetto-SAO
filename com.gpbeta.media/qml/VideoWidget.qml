import QtQuick 2.12
import QtQuick.Controls 2.12
import QtMultimedia 5.13

import NERvGear 1.0 as NVG
import NERvGear.Dialogs 1.0 as D
import NERvGear.Templates 1.0 as T

import "action"

T.Widget {
    id: widget

    property bool playing: true
    property bool videoChanged: false

    function isVideoReady(status) {
        switch (status) {
        case MediaPlayer.Loaded:
        case MediaPlayer.Buffering:
        case MediaPlayer.Stalled:
        case MediaPlayer.Buffered:
        case MediaPlayer.EndOfMedia: return true;
        default: break;
        }
        return false;
    }

    title: NVG.Url.info(player.source).fileName

    solid: true
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

        Action {
            text: qsTr("Mute")
            checkable: true
            checked: player.muted
            onTriggered: muteVideo()
        }

        Menu {
            title: qsTr("Fill Mode")

            Action {
                text: qsTr("Fit")
                checkable: true
                checked: video.fillMode === VideoOutput.PreserveAspectFit
                onTriggered: settings.fillMode = VideoOutput.PreserveAspectFit
            }

            Action {
                text: qsTr("Crop")
                checkable: true
                checked: video.fillMode === VideoOutput.PreserveAspectCrop
                onTriggered: settings.fillMode = VideoOutput.PreserveAspectCrop
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
            text: qsTr("Change Video")

            onTriggered: dialog.open()
        }
    }

    action: VideoWidgetAction {}

    function toggleVideo() {
        if (player.playbackState === MediaPlayer.PlayingState) {
            player.pause();
            playing = false;
        } else {
            player.play();
            playing = true;
        }
    }

    function playVideo() {
        player.play();
        playing = true;
    }

    function stopVideo() {
        player.stop();
        playing = false;
    }

    function muteVideo() {
        settings.muted = !player.muted;
    }

    D.FileDialog {
        id: dialog

        onAccepted: changeVideo(file)
    }

    DropArea {
        anchors.fill: parent

        onEntered: drag.accepted = drag.hasUrls;

        onPositionChanged: drag.action = Qt.LinkAction;

        onDropped: changeVideo(drop.urls[0])

        MediaPlayer {
            id: player
            autoPlay: widget.NVG.View.exposed
            loops: MediaPlayer.Infinite
            muted: widget.settings.muted ?? false
            source: widget.settings.url || ""

            onStatusChanged: {
                if (videoChanged && isVideoReady(status)) {
                    videoChanged = false;
                    autoResizeWidget();
                }
            }
        }

        VideoOutput {
            id: video
            anchors.fill: parent

            source: player
            fillMode: settings.fillMode ?? VideoOutput.PreserveAspectFit
            flushMode: VideoOutput.LastFrame
        }

        Image {
            id: defaultImage
            anchors.centerIn: parent

            visible: !isVideoReady(player.status)
            source: "../Images/video-widget.png"
        }

        MouseArea {
            anchors.fill: parent
            onClicked: toggleVideo()
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

    NVG.View.onExposedChanged: {
        if (!playing)
            return;

        if (NVG.View.exposed)
            player.play();
        else
            player.pause();
    }

    function resetWidgetSize() {
        width = video.implicitWidth;
        height = video.implicitHeight;
        geometryReset();
    }

    function autoResizeWidget() {
        if (settings.autoResize === false)
            return;
        resetWidgetSize();
    }

    function changeVideo(url) {
        settings.url = url;
        if (!defaultImage.visible)
            autoResizeWidget();
        else
            videoChanged = true;
        playing = true;
    }
}
