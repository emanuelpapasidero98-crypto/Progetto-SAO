import QtQuick 2.12
import QtQuick.Controls 2.12

import NERvGear 1.0 as NVG

import "impl" 1.0 as Impl

Flickable {
    id: messageView

    clip: true
    contentWidth: width
    contentHeight: layout.height

    property var message
    property var messagePartFilter
    property string messageHeader

    property bool contentAvailable: false

    readonly property alias content: content

    readonly property Component cRetrieval: Impl.RetrievalAction {
        onActivityChanged: if (activity > Impl.ServiceAction.InProgress) destroy()
    }

    function loadMessage(message) {
        return new Promise(function (resolve, reject) {
            if (message.hasStatusFlag("Incoming") && !message.hasStatusFlag("PartialContentAvailable")) {
                const action = cRetrieval.createObject(messageView);
                action.activityChanged.connect(function () {
                    switch (action.activity) {
                    case Impl.ServiceAction.Successful:
                        // resolve with updated message
                        resolve(mailStore.message(message.id)); break;
                    case Impl.ServiceAction.Failed:
                        reject(action.status.text); break;
                    }
                });
                action.retrieveMessage(message.id, Impl.RetrievalAction.Content);
            } else {
                resolve(message);
            }
        });
    }

    function loadMessagePart(part, cb) {
        return new Promise(function (resolve, reject) {
            if (part.hasBody) {
                resolve(part);
            } else {
                const action = cRetrieval.createObject(messageView);
                action.activityChanged.connect(function () {
                    switch (action.activity) {
                    case Impl.ServiceAction.Successful:
                        resolve(part); break;
                    case Impl.ServiceAction.Failed:
                        reject(action.status.text); break;
                    }
                });
                if (cb)
                    action.progressChanged.connect(function () {
                        cb(action.progress);
                    });
                action.retrieveMessagePart(part.location);
            }
        });
    }

    function findHtmlPart(container) {
        for (let i = 0; i < container.partCount; ++i) {
            const part = container.partAt(i);
            if (part.multipartType !== Impl.Message.MultipartNone) {
                const htmlPart = findHtmlPart(part);
                if (htmlPart)
                    return htmlPart;
            } else {
                const contentType = part.contentType;
                const disposition = part.contentDisposition;
                if (disposition.isNull || disposition.type === Impl.MessageContentDisposition.Attachment)
                    continue;

                if (contentType.type.toString().toLowerCase() === "text" &&
                    contentType.subType.toString().toLowerCase() === "html")
                        return part;
            }
        }
    }

    function viewHtml() {
        if (message.hasBody) {
            return new Promise(function (resolve, reject) {
                const path = mailStore.dumpMessageBody(message);
                if (path) {
                    if (NVG.SystemCall.openFile("file:///" + path))
                        return resolve();
                }
                return reject();
            });
        }

        const htmlPart = findHtmlPart(message);

        if (htmlPart) {
            return loadMessagePart(htmlPart).then(function (part) {
                const updatedMessage = mailStore.message(message.id);
                const updatedPart = updatedMessage.partAt(part.location);
                const path = mailStore.dumpMessagePart(updatedMessage, updatedPart);
                if (path) {
                    if (NVG.SystemCall.openFile("file:///" + path))
                        return Promise.resolve();
                }
                return Promise.reject();
            });
        }

        return Promise.reject();
    }

    function renderMultipartAlternative(container) {
        var bestPart;

        for (let i = 0; i < container.partCount; ++i) {
            const part = container.partAt(i);
            const contentType = part.contentType;
            const subtype = contentType.subType.toString().toLowerCase();
            if (contentType.type.toString().toLowerCase() === "text") {
                if (messagePartFilter && !messagePartFilter(part))
                    continue;

                if (subtype === "plain") {
                    bestPart = part;
                    break;
                } else if (subtype === "html") {
                    if (!bestPart) {
                        bestPart = part;
                    }
                } else {
                    if (bestPart && bestPart.contentType.subType.toString().toLowerCase() === "html")
                        bestPart = part;
                }
            }
        }

        if (bestPart)
            return loadMessagePart(bestPart).then((part)=>[part]);

        return Promise.resolve([]);
    }

    function renderMultipartMixed(container, result) {
        if (container.multipartType !== Impl.Message.MultipartMixed)
            console.warn("unsupported multipart type:", container.contentType);

        const promises = [];

        for (let i = 0; i < container.partCount; ++i) {
            const part = container.partAt(i);
            if (part.multipartType !== Impl.Message.MultipartNone) {
                promises.push(renderMessageMultipart(part));
            } else if (part.contentType.type.toString().toLowerCase() === "text") {
                const disposition = part.contentDisposition;
                if (disposition.isNull || disposition.type === Impl.MessageContentDisposition.Attachment)
                    continue;

                if (messagePartFilter && !messagePartFilter(part))
                    continue;

                promises.push(loadMessagePart(part).then((part)=>[part]));
            }
        }

        // Array.flat()
        return Promise.all(promises).then(function (arrays) {
            return arrays.reduce((acc, val) => acc.concat(val), []);
        });
    }

    function renderMessageMultipart(part) {
        if (part.multipartType === Impl.Message.MultipartAlternative)
            return renderMultipartAlternative(part);

        return renderMultipartMixed(part);
    }

    onMessageChanged: {
        contentAvailable = false;
        busyIndicator.running = true;
        layout.opacity = 0;

        loadMessage(message)
            .then(function (message) {
                if (message.hasBody)
                    return [message];
                return renderMessageMultipart(message);
            })
            .then(function (parts) {
                const updatedMessage = mailStore.message(message.id);
                // message content
                let text = messageHeader;
                let format = TextEdit.AutoText;
                if (parts.length) {
                    const contentType = parts[0].contentType;
                    const subtype = contentType.subType.toString().toLowerCase();

                    if (subtype === "plain")
                        format = TextEdit.PlainText;
                    else if (subtype === "html")
                        format = TextEdit.RichText;

                    parts.forEach(function (part) {
                        const location = part.location;
                        const updatedPart = location ? updatedMessage.partAt(part.location) :
                                                       updatedMessage; // part is message
                        if (updatedPart.hasBody)
                            text += updatedPart.body.data + '\n';
                    });
                } else {
                    text = "<N/A>"
                }

                content.textFormat = format;
                content.text = text;

                // attachments
                const attachments = [];
                for (let i = 0; i < updatedMessage.partCount; ++i) {
                    const part = updatedMessage.partAt(i);
                    if (part.contentDisposition.type === Impl.MessageContentDisposition.Attachment)
                        attachments.push(part);
                }
                attachmentView.model = attachments;
                contentAvailable = true;
            }, function (err) {
                attachmentView.model = undefined;
                content.text = qsTr("<Message Unavailable>") + "\n\n" + err;
                content.textFormat = TextEdit.AutoText;
            })
            .then(function () {
                layout.opacity = 1;
                messageView.contentY = 0;
                busyIndicator.running = false;
            })
            .catch((err)=>console.warn(err));
    }

    Column {
        id: layout
        width: messageView.width

        opacity: 0
        visible: opacity > 0

        Behavior on opacity {
            NumberAnimation { duration: 250 }
        }

        TextEdit {
            id: content
            anchors.left: parent.left
            anchors.right: parent.right

            readOnly: true
            wrapMode: TextEdit.WordWrap

            onLinkActivated: Qt.openUrlExternally(link)
       }

        Label {
            anchors.horizontalCenter: parent.horizontalCenter

            height: 32
            visible: attachmentView.count
            text: "- Attachments -"
            font: content.font
            color: content.color
        }

        Repeater {
            id: attachmentView

            delegate: MessageViewAttachment {
                anchors.left: parent.left
                anchors.right: parent.right

                messagePart: modelData
            }
        }
    }

    BusyIndicator {
        id: busyIndicator
        anchors.centerIn: parent
        parent: messageView
        running: false
        hoverEnabled: false
    }

}
