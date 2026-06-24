import QtQml 2.3

import NERvGear.Templates 1.0 as T

import "impl" 1.0 as Impl

T.Data {
    id: root

    title: qsTr("Mail Box Data")
    description: title

    T.Value {
        name: "unread"
        title: qsTr("Unread Messages")

        status: Impl.Server.mailer ? T.Value.Ready : T.Value.Null
        interval: 1000
        current: 0
        minimum: 0
        maximum: 0

        update.execute: function () {
            const mailer = Impl.Server.mailer;
            if (mailer) {
                current = mailer.pendings.length;
                maximum = mailer.inboxFolder()?.serverCount ?? 0;
            }
        }
    }
}
