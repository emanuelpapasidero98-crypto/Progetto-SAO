import QtQuick 2.12

import NERvGear 1.0 as NVG

import "impl" 1.0 as Impl
import "styles.js" as Styles

NVG.Container {
    id: mailer

    readonly property var style: module.settings.style ? Styles.GGO : Styles.SAO

    readonly property var accountId: {
        const ids = mailStore.queryAccounts(Impl.AccountKey.name("default"));
        if (ids.length)
            return ids[0];

        const account = mailStore.createAccount();
        account.name = "default";
        account.messageType = Impl.Message.Email;

        account.setStatusFlag("Enabled", true);
        account.setStatusFlag("UserEditable", true);
        account.setStatusFlag("UserRemovable", true);

        if (mailStore.addAccount(account.ptr))
            return account.id;

        return null; // impossible
    }

    readonly property var pendings: []
    readonly property bool notificationEnabled: module.settings.notification ?? true

    onNotificationEnabledChanged: {
        if (notificationEnabled)
            notifyPendingMessages();
        else
            notification.active = false;
    }

    property Inbox inbox: null
    property Contacts contacts: null
    property OptionsDialog options: null

    property var inboxFolderLazy: null

    function startup() {
        const key = Impl.MessageKey.qAnd(Impl.MessageKey.status(Impl.Message.Incoming),
                                         Impl.MessageKey.status(Impl.Message.New));
        Array.prototype.push.apply(pendings, mailStore.queryMessages(key));
        const account = currentAccount();
        if (account && account.hasStatusFlag("CanRetrieve"))
            importAction.synchronize(account.id, Impl.RetrievalAction.DefaultMinimum);
        else
            notifyPendingMessages();
    }

    function currentAccount() {
        if (!accountId || !mailStore.validateId(accountId))
            return;

        return mailStore.account(accountId);
    }

    function inboxFolder() {
        if (!inboxFolderLazy) {
            const ids = mailStore.queryFolders(Impl.FolderKey.path("Inbox"));
            if (ids.length && mailStore.validateId(ids[0]))
                inboxFolderLazy = mailStore.folder(ids[0]);
        }

        return inboxFolderLazy;
    }

    function messageQuotePartFilter(part) {
        return part.contentId !== "message-quote@mail-box.gpbeta.com" &&
               part.contentDescription !== "SAO Utils Message Quote";
    }

    function notifyPendingMessages() {
        if (!pendings.length || !notificationEnabled ||
            notification.active || importAction.running || messagePanel.visible)
            return;

        if (pendings.length > 1) {
            notification.title = qsTr("%1 new messages").arg(pendings.length);
        } else {
            notification.title = mailStore.messageMetaData(pendings[0]).subject;
        }

        notification.active = true;
    }

    function readPendingMessage() {
        if (!pendings.length)
            return;

        const id = pendings.shift();
        updateMessageStatus(id, Impl.Message.New, false);
        messagePanel.showMessage(mailStore.message(id));

        notification.active = false;
    }

    function addPendingMessage(message) {
        if (pendings.indexOf(message.id) !== -1)
            return;

        const key = Impl.MessageKey.id(message.id);
        if (!message.hasStatusFlag("New"))
            mailStore.updateMessagesMetaData(key, Impl.Message.New, true);
        if (message.hasStatusFlag("Read"))
            mailStore.updateMessagesMetaData(key, Impl.Message.Read, false);

        pendings.push(message.id);

        notifyPendingMessages();
    }

    function ignorePendingMessages() {
        if (pendings.length) {
            updateMessageStatus(mailStore.messageIdList(pendings), Impl.Message.New, false);
            pendings.length = 0;
        }

        notification.active = false;
    }

    function updateMessageStatus(id, status, set) {
        return mailStore.updateMessagesMetaData(Impl.MessageKey.id(id), status, set);
    }

    function markMessageAsRead(message) {
        if (!message.hasStatusFlag("Read"))
            updateMessageStatus(message.id, Impl.Message.Read, true);
        if (message.hasStatusFlag("New"))
            updateMessageStatus(message.id, Impl.Message.New, false);

        const index = pendings.indexOf(message.id);
        if (index !== -1)
            pendings.splice(index, 1);
    }

    function createMessageComposer(message) {
        return cComposer.createObject(mailer, { replyToMessage: message });
    }

    function createRecipientComposer(recipient) {
        return cComposer.createObject(mailer, { recipient: recipient });
    }

    function createContactComposer(address, name) {
        return createRecipientComposer(name ? name + " <" + address + ">" : address);
    }

    function showContacts() {
        if (contacts)
            contacts.requestActivate();
        else
            contacts = cContacts.createObject(mailer);
    }

    function showInbox() {
        if (inbox)
            inbox.requestActivate();
        else
            inbox = cInbox.createObject(mailer);
    }

    function showOptions() {
        if (options)
            options.requestActivate();
        else
            options = cOptions.createObject(mailer);
    }

    Component {
        id: cComposer
        MessageComposer { onClosing: destroy() }
    }

    Component {
        id: cContacts
        Contacts { onClosing: destroy() }
    }

    Component {
        id: cInbox
        Inbox { onClosing: destroy() }
    }

    Component {
        id: cOptions
        OptionsDialog { onClosing: if (close.accepted) destroy() }
    }

    MessagePanel {
        id: messagePanel

        onVisibleChanged: {
            if (!visible)
                notifyPendingMessages();
        }
    }

    NVG.Notification {
        id: notification

        onAccepted: readPendingMessage()
        onRejected: pendings.length = 0
    }

    Impl.Online {
        id: online
        localeMap: Impl.Server.wxLocaleMap()
    }

    Impl.MailStore {
        id: mailStore

        onMessagesAdded: {
            const ignores = [];

            jsArray(ids).forEach(function (id) {
                const message = messageMetaData(id);
                if (message.hasStatusFlag("New")) {
                    if (message.hasStatusFlag("Read")) {
                        ignores.push(id);
                        return;
                    }

                    pendings.push(id);
                }
            });

            updateMessageStatus(messageIdList(ignores), Impl.Message.New, false);

            notifyPendingMessages();
        }
    }

    Impl.RetrievalAction {
        id: importAction

        onRunningChanged: {
            if (!running)
                notifyPendingMessages();
        }
    }
}
