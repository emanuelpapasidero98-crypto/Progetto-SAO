import QtQuick 2.12

import NERvGear 1.0 as NVG
import NERvGear.Templates 1.0 as T
import NERvGear.Preferences 1.0 as P

import com.gpbeta.private 1.0 as G

G.LauncherTemplate {
    id: launcher

    style: T.Theme.Light

    displayTopMargin: 200
    displayBottomMargin: 300
    displayLeftMargin: 400
    displayRightMargin: 300

    menuAlignHeight: 150
    menuMouseOffset: 32

    view: MainView { id: mainView }

    itemOptions: T.LauncherItemOptions {

        Component {
            id: cMainIconPreview

            IconPreview {
                configuration: ctx_currentItem.icon

                background.defaultBackground {
                    normal: "../Images/background/btn.png"
                    hovered: "../Images/background/btn-hovered.png"
                    pressed: "../Images/background/btn-pressed.png"
                }

                icon.width: 46
                icon.height: 46
                icon.defaultIcon {
                    normal: "../Images/symbol/help.png"
                    hovered: "../Images/symbol/help-hovered.png"
                }
            }
        }

        Component {
            id: cMenuIconPreview

            IconPreview {
                configuration: ctx_currentItem.icon

                background.defaultBackground {
                    normal: "../Images/etc/item-preview.png"
                    hovered: "../Images/etc/item-preview-hovered.png"
                    pressed: "../Images/etc/item-preview-pressed.png"
                }

                icon.width: 26
                icon.height: 26
                icon.anchors.horizontalCenterOffset: -8
                icon.defaultIcon {
                    normal: "../Images/item/help.png"
                    hovered: "../Images/item/help-hovered.png"
                }
            }
        }

        Component {
            id: cItemPreference

            P.ObjectPreferenceGroup {
                defaultValue: ctx_currentItem.theme
                syncProperties: true

                P.SwitchPreference {
                    name: "infoPanel"
                    label: qsTr("Display Information Panel")
                }
            }
        }

        iconPreferableFilter: NVG.ResourceFilter {
            locationPattern: RegExp(ctx_currentItem.parent === ctx_rootItem ?
                                        "/icon/main" : "/icon/item")
            packagePattern: /com.gpbeta.theme.sao/
        }

        iconPreview: itemPreview
        itemPreview: ctx_currentItem.parent === ctx_rootItem ?
                         cMainIconPreview : cMenuIconPreview
        itemPreference: (ctx_currentItem.type === NVG.MenuSettings.FolderItem ||
                         ctx_currentItem.type === NVG.MenuSettings.MenuItem) ?
                            cItemPreference : null
    }
}
