import QtQuick 2.12
import QtQml.Models 2.12
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12

import NERvGear 1.0 as NVG
import NERvGear.Controls 1.0

NVG.Window {
    id: contacts

    property var _currentItem
    property bool _updateFriend: false

    title: qsTr("Contacts")
    visible: true

    minimumWidth: 320
    minimumHeight: 640

    Component.onCompleted: {
        online.loadUsers();
        online.loadFriends();
    }

    Component.onDestruction: {
        online.flushFriends();
    }

    Page {
        id: page
        anchors.fill: parent

        header: ToolBar {
            id: titleBar

            SwipeView {
                id: toolView
                anchors.left: parent.left
                anchors.right: searchButton.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom

                interactive: false

                Item {
                    visible: SwipeView.isCurrentItem

                    TypeLabel {
                        anchors.left: parent.left
                        anchors.leftMargin: 16
                        anchors.verticalCenter: parent.verticalCenter

                        category: TypeLabel.Title
                        text: contacts.title
                    }
                }

                RowLayout {
                    visible: SwipeView.isCurrentItem
                    spacing: 0

                    onVisibleChanged: if (visible) searchField.forceActiveFocus()

                    ToolButton {
                        Layout.alignment: Qt.AlignVCenter

                        icon.name: "regular:\uf060"

                        onClicked: {
                            filterModel.filterOnGroup = "";
                            toolView.setCurrentIndex(0);
                        }
                    }

                    TextField {
                        id: searchField
                        Layout.fillWidth: true
                        onAccepted: {
                            if (searchField.text) {
                                const searchText = searchField.text;
                                for (let i = 0; i < filterModel.items.count; ++i) {
                                    const item = filterModel.items.get(i);
                                    const user = filterModel.model.get(i);

                                    item.inResult = user.name.includes(searchText) ||
                                                    user.mail.includes(searchText);
                                }
                                filterModel.filterOnGroup = "result";
                            } else {
                                filterModel.filterOnGroup = "";
                            }
                        }
                    }
                }
            }

            ToolButton {
                id: searchButton
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter

                icon.name: "regular:\uf002"

                onClicked: {
                    if (toolView.currentIndex) {
                        searchField.accepted();
                    } else {
                        searchField.text = "";
                        toolView.setCurrentIndex(1);
                    }
                }
            }

        }

        footer: TabBar {
            id: naviBar
            anchors.left: parent.left
            anchors.right: parent.right

            currentIndex: 1

            onCurrentIndexChanged: {
                filterModel.filterOnGroup = "";
                toolView.setCurrentIndex(0);
            }

            TabButton {
                text: qsTr("My Friends")
                icon.name: naviBar.currentIndex ? "regular:\uf007" : "solid:\uf007"
                font.pixelSize: 12
                display: AbstractButton.TextUnderIcon
            }

            TabButton {
                text: qsTr("Online Users")
                icon.name: naviBar.currentIndex ? "solid:\uf0ac" : "regular:\uf0ac"
                font.pixelSize: 12
                display: AbstractButton.TextUnderIcon
            }
        }

        DelegateModel {
            id: filterModel

            groups: DelegateModelGroup { name: "result" }

            model: naviBar.currentIndex ? online.usersModel : online.friendsModel

            delegate: ContactsItem {

                iconColor: page.Style.color(((modelData.locale || 0)) % 20)
                iconText: online.localeMap[modelData.locale] || "?"
                nameText: modelData.name || "\u300e\u3000\u300f"
                mailText: modelData.mail
                onlineStatus: naviBar.currentIndex === 0 &&
                              online.usersSet.has(mailText)

                onClicked: {
                    _currentItem = modelData;
                    (naviBar.currentIndex ? userMenu : friendMenu).popup();
                }
            }
        }

        ListView {
            id: usersList
            anchors.fill: parent

            header: ContactsItem {
                iconColor: page.Style.color(page.Style.Grey)
                iconText: "GM"
                nameText: "Joshua GPBeta"
                mailText: "gpbeta@sina.cn"
                onlineStatus: online.usersSet.has(mailText)

                onClicked: mailer.createContactComposer(mailText, nameText)

                Divider {
                    anchors.leftMargin: 16
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.rightMargin: 16
                    anchors.bottom: parent.bottom
                }
            }

            model: filterModel

            ScrollBar.vertical: ScrollBar { }
        }

        Column {
            anchors.centerIn: parent

            TypeLabel {
                anchors.horizontalCenter: parent.horizontalCenter
                enabled: false
                visible: !errorLabel.visible && toolView.currentIndex && usersList.count === 0
                text: qsTr("No records match your search.")
            }

            TypeLabel {
                id: errorLabel
                anchors.horizontalCenter: parent.horizontalCenter
                enabled: false
                visible: online.usersStatus === Loader.Error && naviBar.currentIndex
                text: qsTr("No records currently, please come back later!")
            }

            Button {
                anchors.horizontalCenter: parent.horizontalCenter

                text: qsTr("Reload")
                flat: true
                visible: errorLabel.visible

                onClicked: online.loadUsers()
            }
        }

        RoundButton {
            anchors.right: parent.right
            anchors.rightMargin: 16
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 16

            visible: naviBar.currentIndex === 0
            highlighted: true
            width: 56
            height: 56

            icon.name: "regular:\uf067"

            onClicked: {
                _currentItem = { locale: online.localeCode };
                nameField.clear();
                mailField.clear();
                editDialog.open();
            }
        }

        Dialog {
            id: editDialog
            anchors.centerIn: parent

            modal: true
            title: "Details"
            standardButtons: Dialog.Save

            contentItem: Column {

                TypeLabel {
                    text: qsTr("Name")
                }

                TextField {
                    id: nameField
                    width: 200
                }

                TypeLabel {
                    text: qsTr("Email Address")
                }

                TextField {
                    id: mailField
                    width: 200
                }
            }

            onAccepted: {
                if (mailField.length) {
                    // always deep copy to prevent modifying the model data
                    const info = { name: nameField.text, mail: mailField.text, locale: _currentItem.locale }
                    online.addOrUpdateFriend(info, _currentItem.mail);
                }
            }

            Component.onCompleted: standardButton(Dialog.Save).enabled = Qt.binding(()=>mailField.length)
        }

        Menu {
            id: friendMenu

            MenuItem {
                text: qsTr("Send Message")

                onClicked: mailer.createContactComposer(_currentItem.mail, _currentItem.name)
            }

            MenuItem {
                text: qsTr("Edit Information")
                onClicked: {
                    nameField.text = _currentItem.name;
                    mailField.text = _currentItem.mail;
                    editDialog.open();
                }
            }

            MenuItem {
                text: qsTr("Remove Friend")

                onClicked: online.removeFriend(_currentItem.mail)
            }
        }

        Menu {
            id: userMenu

            MenuItem {
                text: qsTr("Send Message")

                onClicked: mailer.createContactComposer(_currentItem.mail, _currentItem.name)
            }

            MenuItem {
                text: qsTr("Add Friend")

                onClicked: online.addOrUpdateFriend(_currentItem)
            }
        }

    }


}
