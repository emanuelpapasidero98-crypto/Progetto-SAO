import NERvGear.Preferences 1.0
import NERvGear.Templates 1.0 as T

import "impl" 1.0 as Impl

T.Action {
    id: thiz

    enum MailCommand { ComposeMessage, ShowInbox, ShowContacts, ShowOptions, ReadNewMessage }

    title: qsTr("Mail Box Shortcuts")
    description: title

    execute: function () {
        return new Promise(function (resolve, reject) {
            const account = Impl.Server.mailer.currentAccount();

            if (!account.hasStatusFlag("CanRetrieve") && !account.hasStatusFlag("CanTransmit")) {
                Impl.Server.mailer.showOptions();
                return resolve();
            }

            switch (configuration.command) {
            case MailAction.ComposeMessage:
                Impl.Server.mailer.createRecipientComposer(configuration.recipient);
                return resolve();
            case MailAction.ShowInbox: Impl.Server.mailer.showInbox(); return resolve();
            case MailAction.ShowContacts: Impl.Server.mailer.showContacts(); return resolve();
            case MailAction.ShowOptions: Impl.Server.mailer.showOptions(); return resolve();
            case MailAction.ReadNewMessage: Impl.Server.mailer.readPendingMessage(); return resolve();
            default: break;
            }

            reject();
        });
    }

    preference: PreferenceGroup {
        SelectPreference {
            id: pCommand
            name: "command"
            label: qsTr("Command")
            model: [ qsTr("Compose Message"), qsTr("Open Inbox"), qsTr("Show Contacts"),
                     qsTr("Show Options"), qsTr("Read New Message") ]
            defaultValue: 0
        }

        TextFieldPreference {
            name: "recipient"
            label: qsTr("Recipient")
            visible: pCommand.value === MailAction.ComposeMessage
        }
    }
}
