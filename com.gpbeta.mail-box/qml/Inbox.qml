import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

import NERvGear 1.0 as NVG
import NERvGear.Controls 1.0

import "impl" 1.0 as Impl

NVG.Window {
    id: inbox

    title: qsTr("Inbox")
    visible: true

    minimumWidth: 640
    minimumHeight: 480

    property var folderId: resolveInboxFolderId()

    function resolveInboxFolderId() {
        // TODO: check if Qt6 support manual re-evaluation
        const ids = mailStore.queryFolders(Impl.FolderKey.path("Inbox"));
        if (ids.length)
            return ids[0];

        return Impl.Folder.EmptyId;
    }

    function updateMessageListFooter() {
        const folder = mailStore.folder(folderId);

        messageList.footer = folder.hasStatusFlag("PartialContent") ? messageListFooter : null;
    }

    Component.onCompleted: updateMessageListFooter()

    Component {
        id: messageListFooter

        Button {
            anchors.horizontalCenter: parent?.horizontalCenter

            enabled: !importAction.running
            text: qsTr("Load More Messages")

            onClicked: {
                importActionListener.enabled = true;

                let retrievalMinimum = mailStore.countMessages(messageList.model.key);
                retrievalMinimum += Impl.RetrievalAction.DefaultMinimum;

                importAction.retrieveMessageList(mailer.accountId, folderId, retrievalMinimum);
            }
        }
    }

    Connections {
        id: importActionListener

        target: importAction

        onActivityChanged: {
            switch (importAction.activity) {
            case Impl.ServiceAction.Successful:
                if (!mailStore.validateId(folderId))
                    folderId = resolveInboxFolderId(); // try to reload folder ID
                updateMessageListFooter();
                break;
            case Impl.ServiceAction.Failed:
                console.warn(importAction.status.text);
                toast.show(qsTr("Failed to update message list"))
                break;
            }
        }
    }

    Page {
        anchors.fill: parent

        header: TitleBar {
            text: inbox.title

            ToolButton {
                icon.name: "regular:\uf2f1"

                enabled: mailer.accountId && !importAction.running

                ToolTip.visible: hovered
                ToolTip.text: qsTr("Synchronize")

                onClicked: importAction.synchronize(mailer.accountId, Impl.RetrievalAction.DefaultMinimum)
            }

            ToolButton {
                icon.name: "regular:\uf013"
                ToolTip.visible: hovered
                ToolTip.text: qsTr("Options")

                onClicked: mailer.showOptions()
            }
        }

        ProgressBar {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom

//        indeterminate: true
            visible: importAction.running
            value: importAction.progress
        }

        ListView {
            id: messageList
            anchors.fill: parent

            model: Impl.MessageListModel {
                key: Impl.MessageKey.parentFolderId(folderId)
                sortKey: Impl.MessageSortKey.timeStamp(Qt.DescendingOrder)
            }

            delegate: ItemDelegate {

                readonly property var message: mailStore.messageMetaData(id)
                readonly property bool unread: !message.hasStatusFlag("Read")

                width: messageList.width

                contentItem: RowLayout {
                    Icon {
                        Layout.leftMargin: 8
                        Layout.rightMargin: 16

                        icon {
                            width: 20
                            height: 20

                            name: unread ? "solid:\uf0e0" : "regular:\uf2b6"
                        }
                    }

                    Column {
                        Layout.fillWidth: true

                        TypeLabel {
                            anchors.left: parent.left
                            anchors.right: parent.right

                            text: model.subject
                            level: unread ? 2 : 1
                        }

                        TypeLabel {
                            anchors.left: parent.left
                            anchors.right: parent.right

                            text: model.address
                            category: TypeLabel.Caption
                            color: Style.secondaryTextColor
                        }
                    }

                    TypeLabel {
                        text: {
                            const now = new Date;
                            const date = message.date.toLocalTime();

                            // today?
                            if (now.getDate() === date.getDate() &&
                                now.getMonth() === date.getMonth() &&
                                now.getFullYear() === date.getFullYear()) {
                                return Qt.formatTime(date, "hh:mm AP");
                            }

                            return Qt.formatDate(date, "yyyy-MM-dd");
                        }
                    }
                }

                onClicked: {
                    const msg = mailStore.message(id);
                    messagePanel.showMessage(msg);
                }
            }

            ScrollBar.vertical: ScrollBar { }
        }

        RoundButton {
            anchors.right: parent.right
            anchors.rightMargin: 16
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 16

            highlighted: true
            width: 56
            height: 56

            icon.name: "regular:\uf067"

            onClicked: mailer.createMessageComposer()
        }

        Toast { id: toast }
    }

}
