import QtQuick 2.12
import QtQuick.Controls 2.12

import NERvGear 1.0 as NVG
import NERvGear.Controls 1.0
import NERvGear.Dialogs 1.0

import "styles.js" as Styles

Item {
    id: attachmentItem

    property var messagePart

    // private

    property var _part: ({})

    onMessagePartChanged: {
        _part = messagePart;

        iconLabel.text = _part.displayName;
        statusLabel.text = _part.partialContentAvailable ? qsTr("Downloaded") :
                    mailStore.humanReadableSize(_part.contentDisposition.size);
    }

    implicitWidth: 256
    implicitHeight: 32

    MouseArea {
        id: button
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom

        width: Math.min(iconLabel.implicitWidth + 24, attachmentItem.width - statusLabel.width - 16)

        hoverEnabled: true

        onClicked: {
            if (_part.partialContentAvailable) {
                menu.popup();
            } else {
                // download content
                button.enabled = false;
                statusLabel.text = qsTr("Downloading");
                messageView.loadMessagePart(_part, statusLabel.updateProgress)
                    .then(function (part) {
                        _part = mailStore.messagePart(part.location);
                        statusLabel.text = qsTr("Downloaded");
                        button.enabled = true;
                    }, function (err) {
                        console.warn(err);
                        statusLabel.text = qsTr("Download Failed");
                        button.enabled = true;
                    });
            }
        }

        Menu {
            id: menu

            MenuItem {
                text: qsTr("View")

                property url test

                onClicked: {
                    const path = mailStore.dumpMessagePart(messageView.message, _part);
                    if (path)
                        NVG.SystemCall.openFile("file:///" + path);
                }
            }

            MenuItem {
                text: qsTr("Save")

                onClicked: folderDialog.open()
            }
        }

        Rectangle {
            anchors.fill: parent
            visible: button.containsMouse
            color: Styles.color(mailer.style.background, true, button.pressed)
        }

        IconLabel {
            id: iconLabel
            anchors.fill: parent
            anchors.leftMargin: 8
            anchors.rightMargin: 8

            spacing: 8
            color: button.containsMouse ? mailer.style.foreground.hovered : messageView.content.color
            font: messageView.content.font

            icon.source: Styles.icon(mailer.style.icon.attachment, button.containsMouse)
            icon.width: 26
            icon.height: 26
        }
    }

    TypeLabel {
        id: statusLabel
        anchors.right: parent.right
        anchors.rightMargin: 8
        anchors.verticalCenter: parent.verticalCenter

        opacity: 0.75
        color: mailer.style.foreground.normal
        category: TypeLabel.Caption

        function updateProgress(progress) {
            statusLabel.text = qsTr("Downloading") + " " + Math.round(progress * 100) + "%";
        }
    }

    FolderDialog {
        id: folderDialog

        onAccepted: _part.writeBodyTo(NVG.Url.toLocalFile(folder))
    }
}
