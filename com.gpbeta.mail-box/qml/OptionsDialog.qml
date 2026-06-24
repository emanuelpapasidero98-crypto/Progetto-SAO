import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

import NERvGear 1.0 as NVG
import NERvGear.Controls 1.0
import NERvGear.Preferences 1.0 as P

import "impl" 1.0 as Impl

NVG.Window {
    id: dialog

    property var account: mailer.accountId ? mailStore.account(mailer.accountId) : null
    property var originalConfig: mailer.accountId ? mailStore.accountConfiguration(mailer.accountId) : null

    property bool syncRequired: false
    property bool configDirty: false

    title: "Mail Box"
    visible: true
    minimumWidth: 360
    minimumHeight: 720

    onClosing: close.accepted = page.enabled

    Component.onCompleted: {
        if (importAction.running) {
            importAction.cancelOperation();
            syncRequired = true;
        }

        if (account && originalConfig) {
            const services = originalConfig.services();
            const from = account.fromAddress;
            pAddress.value = from.address;
            // NOTE: QMailAddress::name returns address if name is empty
            if (from.name !== from.address)
                pNickname.value = from.name;
            pSignature.value = account.signature;

            pStyle.load(module.settings.style);
            pHistory.load(module.settings.messageHistory);
            pNotification.load(module.settings.notification);

            if (services.includes("imap4")) {
                const imap = originalConfig.serviceConfiguration("imap4");

                pUsername.value = imap.value("username");
                pPassword.value = Qt.atob(imap.value("password"));

                pInServer.value = imap.value("server");
                pInPort.value = imap.value("port", "143");
                pInSecure.value = imap.value("encryption", "0");

                switch (imap.value("checkInterval")) {
                case "1":  pInterval.value = 0; break;
                case "5":  pInterval.value = 1; break;
                case "15": pInterval.value = 2; break;
                case "30": pInterval.value = 3; break;
                case "60": pInterval.value = 4; break;
                }
            }

            if (services.includes("smtp")) {
                const smtp = originalConfig.serviceConfiguration("smtp");

                pOutServer.value = smtp.value("server");
                pOutPort.value = smtp.value("port", "25");
                pOutSecure.value = smtp.value("encryption", "0");
            }
        }
    }

    Component.onDestruction: {
        if (configDirty) { // restore configuration
            mailStore.updateAccount(account.ptr, originalConfig.ptr);
        }

        if (syncRequired) {
            if (account.hasStatusFlag("CanRetrieve"))
                importAction.synchronize(account.id, Impl.RetrievalAction.DefaultMinimum);
        }
    }

    function updateIncomingConfiguration(config, services) {
        if (!services.includes("imap4"))
            config.addServiceConfiguration("imap4");

        const imap = config.serviceConfiguration("imap4");

        imap.setValue("version", "100");
        imap.setValue("servicetype", "source");

        imap.setValue("username", pUsername.value);
        imap.setValue("password", Qt.btoa(pPassword.value));

        imap.setValue("server", pInServer.value);
        imap.setValue("port", pInPort.value || "143");
        imap.setValue("encryption", pInSecure.value);

        let interval = "5";
        switch (pInterval.value) {
        case 0: interval = "1"; break;
        case 1: interval = "5"; break;
        case 2: interval = "15"; break;
        case 3: interval = "30"; break;
        case 4: interval = "60"; break;
        }
        imap.setValue("checkInterval", interval);

        imap.setValue("canDelete", "0");
        imap.setValue("autoDownload", "0");
        imap.setValue("maxSize", "0");
        imap.setValue("textSubtype", "plain");
        imap.setValue("pushEnabled", "0");
        imap.setValue("intervalCheckRoamingEnabled", "1");
    }

    function updateOutgoingConfiguration(config, services) {
        if (!services.includes("smtp"))
            config.addServiceConfiguration("smtp");

        const smtp = config.serviceConfiguration("smtp");

        smtp.setValue("version", "100");
        smtp.setValue("servicetype", "sink");

        smtp.setValue("username", pUsername.value);
        smtp.setValue("address", pAddress.value);

        smtp.setValue("server", pOutServer.value);
        smtp.setValue("port", pOutPort.value || "25");
        smtp.setValue("encryption", pOutSecure.value);

        smtp.setValue("authentication", "1");
        smtp.setValue("smtpusername", pUsername.value);
        smtp.setValue("smtppassword", Qt.btoa(pPassword.value));
    }

    Page {
        id: page
        anchors.fill: parent

        enabled: !inTestAction.running && !outTestAction.running

        header: TitleBar {
            text: dialog.title

            standardButtons: Dialog.Save

            onAccepted: {
                module.settings.style = pStyle.save();
                module.settings.messageHistory = pHistory.save();
                module.settings.notification = pNotification.save();

                if (account) {
                    const config = mailStore.accountConfiguration(account.id);
                    const services = config.services();

                    updateIncomingConfiguration(config, services);
                    updateOutgoingConfiguration(config, services);

                    account.fromAddress = mailStore.createAddress(pNickname.value || pAddress.value, pAddress.value);
                    account.signature = pSignature.value;

                    account.setStatusFlag("MessageSource", true);
                    account.setStatusFlag("MessageSink", true);
                    account.setStatusFlag("CanRetrieve", pUsername.value && pInServer.value);
                    account.setStatusFlag("CanTransmit", pUsername.value && pOutServer.value);

                    mailStore.updateAccount(account.ptr, config.ptr);
                }
                configDirty = false;
                dialog.close();
            }
        }

        Dialog {
            id: resultDialog
            anchors.centerIn: parent

            modal: true
            standardButtons: Dialog.Ok
            contentItem: Label {
                id: resultLabel
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
            }
        }

        Column {
            anchors.fill: parent
            anchors.leftMargin: 16
            anchors.rightMargin: 16

            P.PreferenceGroup {
                width: parent.width

                label: qsTr("Account Settings")

                P.TextFieldPreference {
                    id: pAddress
                    display: P.TextFieldPreference.ExpandControl
                    label: qsTr("Email")
                    hint: "abc@example.com"

                    onPreferenceEdited: {
                        const atPos = value.indexOf("@");
                        if (atPos !== -1) {
                            const domain = value.slice(atPos + 1);
                            if (!pInServer.value)
                                pInServer.value = "imap." + domain;
                            if (!pOutServer.value)
                                pOutServer.value = "smtp." + domain;
                        }
                    }
                }

                P.TextFieldPreference {
                    id: pUsername
                    display: P.TextFieldPreference.ExpandControl
                    label: qsTr("Username")
                }

                P.TextFieldPreference {
                    id: pPassword
                    display: P.TextFieldPreference.ExpandControl
                    label: qsTr("Password")
                    echoMode: TextInput.Password
                }

                P.DialogPreference {
                    label: qsTr("Incoming Server")
                    displayValue: "IMAP"
                    live: true

                    P.TextFieldPreference {
                        id: pInServer
                        hint: "imap.example.com"
                        label: qsTr("IMAP Server")
                    }

                    OptionsDialogPortPreference {
                        id: pInPort
                        defaultValue: 143
                    }

                    P.SelectPreference {
                        id: pInSecure
                        label: qsTr("Secure")
                        model: [ qsTr("None"), "SSL", "TLS" ]
                        defaultValue: 0

                        onPreferenceEdited: {
                            switch (value) {
                            case 0: pInPort.value = 143; break;
                            case 1:
                            case 2: pInPort.value = 993; break;
                            }
                        }
                    }

                }

                P.DialogPreference {
                    label: qsTr("Outgoing Server")
                    displayValue: "SMTP"
                    live: true

                    P.TextFieldPreference {
                        id: pOutServer
                        hint: "smtp.example.com"
                        label: qsTr("SMTP Server")
                    }

                    OptionsDialogPortPreference {
                        id: pOutPort
                        defaultValue: 25
                    }

                    P.SelectPreference {
                        id: pOutSecure
                        label: qsTr("Secure")
                        model: [ qsTr("None"), "SSL", "TLS" ]
                        defaultValue: 0

                        onPreferenceEdited: {
                            switch (value) {
                            case 0: pOutPort.value = 25; break;
                            case 1:
                            case 2: pOutPort.value = 465; break;
                            }
                        }
                    }
                }

                Button {
                    text: qsTr("Test Account Settings")
                    highlighted: true
                    Style.background: dialog.Style.primaryColor

                    onClicked: {
                        if (!pAddress.value) {
                            resultLabel.text = qsTr("Please input email address!");
                            resultDialog.open();
                            return;
                        }

                        if (!pUsername.value) {
                            resultLabel.text = qsTr("Please input username!");
                            resultDialog.open();
                            return;
                        }

                        if (!pInServer.value) {
                            resultLabel.text = qsTr("Please input IMAP server address!");
                            resultDialog.open();
                            return;
                        }

                        if (!pOutServer.value) {
                            resultLabel.text = qsTr("Please input SMTP server address!");
                            resultDialog.open();
                            return;
                        }

                        if (account) {
                            const config = mailStore.accountConfiguration(account.id);
                            const services = config.services();

                            updateIncomingConfiguration(config, services);
                            updateOutgoingConfiguration(config, services);

                            if (mailStore.updateAccountConfiguration(config.ptr)) {
                                inTestAction.retrieveFolderList(account.id, Impl.Folder.EmptyId);
                                configDirty = true;
                            }
                        }
                    }
                }
            }

            P.PreferenceGroup {
                width: parent.width

                label: qsTr("General Settings")

                P.SelectPreference {
                    id: pStyle
                    label: qsTr("Style")
                    model: [ "SAO", "GGO" ]
                    defaultValue: 0
                }

                P.SwitchPreference {
                    id: pNotification
                    label: qsTr("Message Notification")
                    defaultValue: true
                }

                P.SwitchPreference {
                    id: pHistory
                    label: qsTr("Message History")
                    message: qsTr("Adds message history in reply")
                    defaultValue: true
                }

                P.SelectPreference {
                    id: pInterval
                    label: qsTr("Message Checking Interval")
                    model: [ qsTr("1 Minute"), qsTr("5 Minutes"), qsTr("15 Minutes"), qsTr("30 Minutes"), qsTr("1 Hour") ]
                    defaultValue: 1
                }

                P.TextFieldPreference {
                    id: pNickname
                    label: qsTr("Nickname")
                    display: P.TextFieldPreference.ExpandLabel
                }

                P.TextFieldPreference {
                    id: pSignature
                    label: qsTr("Signature")
                    hint: qsTr("- Message Sent from SAO Utils 2 Mail Box")
                }
            }
        }
    }

    Impl.RetrievalAction {
        id: inTestAction

        onActivityChanged: {
            switch (activity) {
            case Impl.ServiceAction.Successful:
                outTestAction.transmitMessages(account.id);
                break;
            case Impl.ServiceAction.Failed:
                let error = "IMAP " + qsTr("Server Test Failed!") + "\n\n";
                const brs = status.text.indexOf("\n\n");
                if (brs === -1)
                    error += status.text;
                else
                    error += status.text.slice(brs + 2);

                resultLabel.text = error;
                resultDialog.open();
                break;
            }
        }
    }

    Impl.TransmitAction {
        id: outTestAction

        onActivityChanged: {
            switch (activity) {
            case Impl.ServiceAction.Successful:
                resultLabel.text = qsTr("Mail Server Test Passed!");
                resultDialog.open();
                break;
            case Impl.ServiceAction.Failed:
                let error = "SMTP " + qsTr("Server Test Failed!") + "\n\n";
                const brs = status.text.indexOf("\n\n");
                if (brs === -1)
                    error += status.text;
                else
                    error += status.text.slice(brs + 2);

                resultLabel.text = error;
                resultDialog.open();
                break;
            }
        }
    }
}
