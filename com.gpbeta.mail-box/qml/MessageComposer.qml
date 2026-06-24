import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

import NERvGear 1.0 as NVG
import NERvGear.Dialogs 1.0 as D
import NERvGear.Controls 1.0

import "impl" 1.0 as Impl

NVG.Window {
    id: messageComposer

    property alias recipient: toField.text
    property var replyToMessage
    property var _draftMessage
    property int _currentAttachment: -1

    readonly property QtObject _settingsDialogFooter: DialogButtonBox {
        Button {
            flat: false
            text: qsTr("Go To Settings")
            DialogButtonBox.buttonRole: DialogButtonBox.RejectRole

            onClicked: mailer.showOptions()
        }
    }

    title: qsTr("Compose Message")
    visible: true

    minimumWidth: layout.implicitWidth
    minimumHeight: 600

    Page {
        anchors.fill: parent

        header: TitleBar {
            text: messageComposer.title

            Style.primary: messageComposer.Style.dialogColor

            Button {
                text: qsTr("Send")
                highlighted: true
                enabled: !transmitAction.running

                onClicked: {
                    if (!toField.text) {
                        dialogContent.text = qsTr("Please input a valid recipient address");
                        dialog.footer = defaultDialogFooter;
                        dialog.open();
                        return;
                    }

                    const account = mailer.currentAccount();

                    if (!account || !account.hasStatusFlag("CanTransmit")) {
                        dialogContent.text = qsTr("Incomplete account configuration");
                        dialog.footer = _settingsDialogFooter;
                        dialog.open();
                        return;
                    }

                    let addOrUpdateMessage;

                    if (_draftMessage) {
                        if (mailStore.validateId(_draftMessage.id))
                            addOrUpdateMessage = mailStore.updateMessage.bind(mailStore);
                        else
                            addOrUpdateMessage = mailStore.addMessage.bind(mailStore);
                    } else {
                        addOrUpdateMessage = mailStore.addMessage.bind(mailStore);
                        _draftMessage = mailStore.createMessage();
                        _draftMessage.messageType = Impl.Message.Email;
                        _draftMessage.parentAccountId = account.id;
                        _draftMessage.parentFolderId = Impl.Folder.LocalStorageFolderId;
                        _draftMessage.from = account.fromAddress;
                        _draftMessage.multipartType = Impl.Message.MultipartMixed;
                        _draftMessage.setStatusFlag("LocalOnly", true);
                        _draftMessage.setStatusFlag("ContentAvailable", true);
                        _draftMessage.setStatusFlag("PartialContentAvailable", true);
                        _draftMessage.setStatusFlag("Outbox", true);
                        _draftMessage.setStatusFlag("Read", true);
                        _draftMessage.setHeaderField("X-Mailer", "SAO Utils Mail Box 2");

                        if (replyToMessage) {
                            _draftMessage.responseType = Impl.Message.Reply;
                            _draftMessage.inResponseTo = replyToMessage.id;

                            let references = replyToMessage.headerFieldText("References") ||
                                             replyToMessage.headerFieldText("In-Reply-To");
                            const replyId = replyToMessage.headerFieldText("Message-ID");

                            if (replyId) {
                                _draftMessage.setHeaderField("In-Reply-To", replyId);
                                references = references ? (references + ' ' + replyId) : replyId;
                            }

                            if (references)
                                _draftMessage.setHeaderField("References", references);
                        } else {

                        }
                    }

                    _draftMessage.date = Impl.TimeStamp.currentDateTime();
                    _draftMessage.to = Impl.Address.fromStringList(toField.text);
                    _draftMessage.subject = subjectField.text;
                    _draftMessage.clearParts();

                    const textContentType = mailStore.createMessageContentType("text/plain; charset=UTF-8");
                    const bodyPart = mailStore.createMessagePart();
                    bodyPart.contentId = "message-body@mail-box.gpbeta.com";
                    bodyPart.contentDescription = "SAO Utils Message Body";
                    bodyPart.body = Impl.MessageBody.fromData(bodyArea.text, textContentType, Impl.MessageBody.Base64);
                    _draftMessage.appendPart(bodyPart);

                    if (replyToMessage && originalMessage.contentAvailable) {
                        const quotePart = mailStore.createMessagePart();
                        quotePart.contentId = "message-quote@mail-box.gpbeta.com";
                        quotePart.contentDescription = "SAO Utils Message Quote";
                        quotePart.body = Impl.MessageBody.fromData(originalMessage.content.text, textContentType, Impl.MessageBody.Base64);
                        _draftMessage.appendPart(quotePart);
                    }

                    for (let i = 0; i < attachmentModel.count; ++i) {
                        const attachment = attachmentModel.get(i);

                        const mimeType = mailStore.mimeTypeFromFileName(attachment.fileName);
                        const contentType = mailStore.createMessageContentType(mimeType);
                        contentType.name = attachment.fileName;

                        const disposition = mailStore.createMessageContentDisposition(Impl.MessageContentDisposition.Attachment);
                        disposition.fileName = attachment.fileName;
                        disposition.size = attachment.fileSize;

                        const attachmentPart = Impl.MessagePart.fromFile(attachment.filePath,
                                                                         disposition,
                                                                         contentType,
                                                                         Impl.MessageBody.Base64,
                                                                         Impl.MessageBody.RequiresEncoding);

                        _draftMessage.appendPart(attachmentPart);
                    }

                    const indicativeSize = _draftMessage.indicativeSize;

                    _draftMessage.size = indicativeSize * 1024;

                    // show accurate progress when >= 1MB
                    progressBar.indeterminate = indicativeSize < 1024;

                    if (addOrUpdateMessage(_draftMessage.ptr)) {
                        transmitAction.transmitMessage(_draftMessage.id);
                    } else {
                        dialogContent.text = qsTr("Cannot create message");
                        dialog.footer = defaultDialogFooter;
                        dialog.open();
                    }
                }
            }
        }

        RowLayout {
            id: layout
            anchors.fill: parent

            spacing: 0
            enabled: !transmitAction.running

            ColumnLayout {
                Layout.minimumWidth: 300
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.margins: 16

                LabelTextField {
                    id: fromField
                    Layout.fillWidth: true

                    enabled: false
                    labelText: qsTr("From")
                }


                LabelTextField {
                    id: toField
                    Layout.fillWidth: true

                    labelText: qsTr("To")
                }

                LabelTextField {
                    id: subjectField
                    Layout.fillWidth: true

                    text: qsTr("<Untitled>")
                    labelText: qsTr("Subject")
                }

                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

                    TextArea {
                        id: bodyArea
                        wrapMode: TextArea.Wrap
                    }
                }

                ToolButton {
                    topInset: 0
                    bottomInset: 0
                    leftInset: 0
                    rightInset: 0

                    background.implicitHeight: 24
                    background.implicitWidth: 24

                    text: attachmentModel.count || ""
                    icon.name: "regular:\uf0c6"

                    onClicked: drawer.open()
                }
            }

            Rectangle {
                Layout.preferredWidth: 6
                Layout.fillHeight: true

                visible: replyToMessage ? true : false
                color: messageComposer.Style.primary
            }

            ColumnLayout {
                Layout.minimumWidth: 300
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.margins: 16
                Layout.topMargin: 0

                spacing: 0
                visible: replyToMessage ? true : false

                Heading {
                    Layout.fillWidth: true
                    leftPadding: 0
                    text: qsTr("Original Message")
                }

                MessageView {
                    id: originalMessage
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    content {
                        color: bodyArea.color
                        font: bodyArea.font
                        selectByMouse: true
                        selectByKeyboard: true
                        selectionColor: messageComposer.Style.accentColor
                        selectedTextColor: messageComposer.Style.primaryHighlightedTextColor
                    }
                    // TODO: contains history settings
                    message: replyToMessage
                    messageHeader: !replyToMessage ? "" :
                        "\n> " + message.from.name + " @ " + message.date.toRfc2822LocalTimeString() + "\n\n"

                    // TODO: check if QML6 can override value type properties
                    Component.onCompleted: content.font.pixelSize = 13
                }
            }
        }

        ProgressBar {
            id: progressBar
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom

            visible: transmitAction.running
        }

        Drawer {
            id: drawer
            width: parent.width
            height: 320
            edge: Qt.BottomEdge

            D.FileDialog {
                id: attachmentDialog
                fileMode: D.FileDialog.OpenFile
                onAccepted: {
                    const path = NVG.Url.toLocalFile(file);
                    const size = mailStore.fileSize(path);
                    const data = {
                        fileName: NVG.Url.info(file).fileName,
                        filePath: path,
                        fileSize: mailStore.humanReadableSize(size)
                    };

                    if (_currentAttachment < 0)
                        attachmentModel.append(data);
                    else
                        attachmentModel.set(_currentAttachment, data);
                }
            }

            ListView {
                id: attachmentView
                anchors.topMargin: 16
                anchors.bottomMargin: 16
                anchors.fill: parent

                // BUG: Window content overflow
                bottomMargin: messageComposer.height - messageComposer.contentItem.height

                clip: true
                model: ListModel { id: attachmentModel }
                delegate: ItemDelegate {
                    id: button
                    anchors.left: parent.left
                    anchors.right: parent.right

                    leftPadding: 24
                    rightPadding: 24

                    onClicked: {
                        _currentAttachment = index;
                        attachmentDialog.open();
                    }

                    contentItem: RowLayout {

                        spacing: 16

                        Icon {
                            icon {
                                width: 16
                                height: 16
                                name: "regular:\uf15b"
                            }
                        }

                        TypeLabel {
                            Layout.fillWidth: true
                            text: fileName
                        }

                        TypeLabel {
                            visible: !button.hovered
                            category: TypeLabel.Caption
                            text: fileSize
                            color: messageComposer.Style.secondaryTextColor
                        }

                        Item {
                            width: 24
                            visible: button.hovered

                            ToolButton {
                                anchors.centerIn: parent
                                icon.name: "regular:\uf068"

                                onClicked: attachmentModel.remove(index)
                            }
                        }
                    }
                }

                footer: RoundButton {
                    anchors.horizontalCenter: parent.horizontalCenter
                    icon.name: "regular:\uf067"

                    highlighted: true
                    leftPadding: 32
                    rightPadding: 32
                    text: qsTr("Add Attachment")

                    onClicked: {
                        _currentAttachment = -1;
                        attachmentDialog.open();
                    }
                }
            }
        }

        Dialog {
            id: dialog
            anchors.centerIn: parent

            modal: true
            title: "Error"
            standardButtons: Dialog.Ok
            footer: DialogButtonBox { id: defaultDialogFooter }

            contentItem: Label {
                id: dialogContent
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }

    Impl.TransmitAction {
        id: transmitAction

        property bool failed: false

        onMessagesFailedTransmission: failed = true

        onActivityChanged: {
            switch (activity) {
            case Impl.ServiceAction.InProgress:
                failed = false;
                break;
            case Impl.ServiceAction.Successful:
                if (failed) {
                    dialogContent.text = qsTr("Invalid mail address");
                    dialog.footer = defaultDialogFooter;
                    dialog.open();
                } else {
                    mailStore.removeMessage(_draftMessage.id);
                    _draftMessage = null;
                    messageComposer.close();
                    NVG.SystemCall.messageBox({text: qsTr("Message sent.")});
                    NVG.SystemCall.playSound(NVG.SFX.NotifyMessage);
                }
                break;
            case Impl.ServiceAction.Failed:
                let error = qsTr("Failed to send mail") + "\n\n";
                const brs = status.text.indexOf("\n\n");
                if (brs === -1)
                    error += '[' + status.text.slice(0, -1) + ']';
                else
                    error += status.text.slice(brs + 2);

                dialogContent.text = error;
                dialog.footer = defaultDialogFooter;
                dialog.open();
                break;
            }
        }
    }

    Component.onCompleted: {
        // layout.implicitWidth may chagne when resizing,
        // we have to break the connection to prevent minimumWidth changing
        minimumWidth = layout.implicitWidth;

        const account = mailer.currentAccount();

        if (account) {
            fromField.text = account.fromAddress.toString();
            const signature = account.signature || qsTr("- Sent from SAO Utils 2 Mail Box");
            bodyArea.text = "\n\n" + signature;

            if (module.settings.messageHistory === false)
                originalMessage.messagePartFilter = mailer.messageQuotePartFilter;
        }

        if (replyToMessage) {
            toField.text = replyToMessage.from.toString();
            subjectField.text = replyToMessage.subject;
        }
    }

    Component.onDestruction: {
        if (_draftMessage) {
            if (mailStore.validateId(_draftMessage.id))
                mailStore.removeMessage(_draftMessage.id);
        }
    }
}
