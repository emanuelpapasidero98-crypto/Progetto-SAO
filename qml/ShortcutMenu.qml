import QtQuick 2.12

import NERvGear 1.0 as NVG
import NERvGear.Templates 1.0 as T
import com.gpbeta.common 1.0 as G

G.QuickMenuTemplate {
    id: shortcutMenu

    readonly property NVG.View widgetView: parent.NVG.View.view

    visible: menuView.visible
    style: T.Theme.Light

    iconPreview: IconPreview {
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

    iconPreferableFilter: NVG.ResourceFilter {
        locationPattern: RegExp("/icon/item")
        packagePattern: /com.gpbeta.theme.sao/
    }

    onOpen: menuView.showMenu()
    onClose: menuView.hideMenu()

    IndicatorView {
        id: indicatorView
        target: menuView.opened ? menuView : null
        compositor: widgetView.compositor
        x: widgetView.x + widgetView.width + 4
        y: widgetView.y + (widgetView.height - height) / 2
        z: widgetView.z
    }

    MenuView {
        id: menuView
        compositor: widgetView.compositor
        x: widgetView.x + widgetView.width + 10
        y: widgetView.y + (widgetView.height - height) / 2
        z: widgetView.z
        parentItem: QtObject {
            readonly property QtObject items: ctx_items
        }
    }
}
