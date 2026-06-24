import QtQuick 2.12
import QtGraphicalEffects 1.0

import NERvGear 1.0 as NVG

import "utils.js" as Utils

NVG.View {
    id: menuView

    property NVG.View parentMenu
    property QtObject parentItem

    readonly property bool opened: visible && !aniFadeOut.running

    readonly property int btnHeight: 46
    readonly property int btnMargin: -2
    readonly property int btnHalfHeight: btnHeight / 2

    readonly property int visibleCount: Math.min(itemMenu.count, itemMenu.pathItemCount)
    readonly property bool snapItems: itemMenu.count < itemMenu.pathItemCount

    readonly property int contentHeight: visibleCount * btnHeight + (visibleCount - 1) * btnMargin
    readonly property int paddingTop: (itemMenu.height - contentHeight) / 2

    property ItemButton currentChecked

    z: 1
    solid: false
    color: "transparent"
    compositor: NVG.LauncherCompositor
    width: 182
    height: 310

    onCurrentCheckedChanged: {
        if (!parentMenu.currentChecked) // hiding by parent
            return;

        if (currentChecked)
            launcher.updateRightEdge(x + width * 2);
        else
            launcher.updateRightEdge(x + width);
    }

    function showMenu() {
        if (visible) {
            if (aniFadeOut.running)
                aniFadeOut.stop();
            else
                return;
        }

        // reset position
        const realVisibleCount = Math.min(itemMenu.count, itemMenu.pathItemCount - 1);
        const duration = itemMenu.highlightMoveDuration;
        itemMenu.highlightMoveDuration = 0;
        itemMenu.currentIndex = realVisibleCount / 2; // move first item to top
        itemMenu.highlightMoveDuration = duration;
        itemMenuTranslate.y = 0;

        visible = true;
        opacity = 0;

        aniFadeIn.start();
    }

    function hideMenu() {
        if (!visible || aniFadeOut.running)
            return;

        if (currentChecked) {
            currentChecked.checked = false;
            currentChecked = null;
        }

        aniFadeIn.stop();
        aniFadeOut.start();
    }

    ParallelAnimation {
        id: aniFadeIn
        NumberAnimation { target: menuView; property: "opacity"; duration: 400; from: 0; to: 1 }
        NumberAnimation {
            target: itemMenuTranslate
            property: "y"
            duration: 600
            from: -menuView.height
            to: 0
            easing.type: Easing.OutQuart
        }
        SequentialAnimation {
            PauseAnimation { duration: 300 }
            ScriptAction { script: NVG.SystemCall.playSound(NVG.SFX.PopupMenu) }
        }
    }

    SequentialAnimation {
        id: aniFadeOut
        ParallelAnimation {
            NumberAnimation { target: menuView; property: "opacity"; duration: 400; from: 1; to: 0 }
            NumberAnimation {
                target: itemMenuTranslate
                property: "y"
                duration: 300
                to: -menuView.height
                easing.type: Easing.InQuad
            }
        }
        PropertyAction { target: menuView; property: "visible"; value: false }
    }

    IndicatorView {
        id: indicatorView
        x: menuView.x + menuView.width - 16
        y: menuView.y + (menuView.height - height) / 2
    }

    Item {
        anchors.fill: parent

        layer {
            enabled: true
            effect: OpacityMask {
                maskSource: Image { source: "../Images/background/item-mask.png" }
            }
        }

        PathView {
            id: itemMenu
            anchors.fill: parent

            pathItemCount: 8
            // BUG: cacheItemCount causing infinity delegate creation
//            cacheItemCount: pathItemCount + 1
            snapMode: snapItems ? PathView.SnapOneItem : PathView.NoSnap
            highlightMoveDuration: 250
            preferredHighlightBegin: 0.5
            preferredHighlightEnd: 0.5

            onMovementStarted: if (currentChecked) currentChecked.checked = false

            model: parentItem.items
            delegate: ItemButton {
                id: button

                text: modelData.label
                iconConfiguration: modelData.icon
                transform: (snapItems && !currentChecked) ? snapTranslate : null

                background.opacity: currentChecked && !checked ? 0.5 : 1.0

                defaultIcon: {
                    switch (modelData.type) {
                    case NVG.MenuSettings.FolderItem:
                    case NVG.MenuSettings.FolderDirItem: return Utils.folderIcon;
                    case NVG.MenuSettings.FolderFileItem: return Utils.fileIcon;
                    }

                    return Utils.helpIcon;
                }

                Translate {
                    id: snapTranslate
                    // FIXME: flickering caused by unexpect layout round-off error
                    y: btnHalfHeight - ((button.y - paddingTop + btnHalfHeight + 0.01) % (btnHeight + btnMargin))
                }

                Loader {
                    id: menuLoader
                    asynchronous: false
                }

                NVG.ActionSource {
                    id: actionSource
                    text: modelData.label || this.title
                    configuration: modelData.action
                }

                onCheckedChanged: {
                    if (checked) {
                        if (modelData.items) {
                            currentChecked = button;

                            itemMenu.currentIndex = index;

                            // reload root folder items
                            if (modelData.type === NVG.MenuSettings.FolderItem)
                                modelData.items.reload();

                            if (!menuLoader.item) {
                                // workaround for instantiating component recursively
                                menuLoader.setSource("MenuView.qml", {
                                    parentMenu: menuView,
                                    parentItem: modelData,
                                    x: Qt.binding(()=>menuView.x + menuView.width - 10),
                                    y: Qt.binding(()=>menuView.y)
                                });
                            }
                            menuLoader.item.showMenu();
                            indicatorView.target = menuLoader.item;
                        } else {
                            checked = false;
                            actionSource.trigger(button);

                            // standalone mode (shortcut menu)
                            if (!parentMenu)
                                hideMenu();
                        }
                        if (modelData.theme?.infoPanel) {
                            // ignore folder sub-dirs
                            if (modelData.type === NVG.MenuSettings.MenuItem ||
                                modelData.type === NVG.MenuSettings.FolderItem)
                                panelView.target = modelData;
                        } // else keep previous panel
                    } else {
                        if (currentChecked === button) {
                            indicatorView.target = null;
                            currentChecked = null;
                        }
                        if (menuLoader.item)
                            menuLoader.item.hideMenu();
                    }
                }

                PathView.onIsCurrentItemChanged: {
                    if (!PathView.isCurrentItem)
                        checked = false;
                }
            }

            path: Path {
                startX: itemMenu.width / 2
                startY: paddingTop
                PathLine {
                    relativeX: 0
                    relativeY: contentHeight + btnMargin
                }
            }

            transform: Translate { id: itemMenuTranslate }
        }
    }
}
