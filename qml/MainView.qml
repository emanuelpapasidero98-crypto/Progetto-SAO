import QtQuick 2.12
import QtGraphicalEffects 1.0

import NERvGear 1.0 as NVG
import NERvGear.Templates 1.0 as T

T.LauncherView {
    id: mainView

    readonly property int btnSize: 64
    readonly property int btnMargin: 6
    readonly property int btnHalfSize: btnSize / 2

    readonly property int visibleCount: Math.min(mainMenu.count, mainMenu.pathItemCount)
    readonly property bool snapItems: mainMenu.count < mainMenu.pathItemCount

    readonly property int contentHeight: visibleCount * btnSize + (visibleCount - 1) * btnMargin
    readonly property int paddingTop: Math.max(mainMenu.height - contentHeight, 0) / 2

    property MainButton currentChecked

    signal fadeInAnimationStarted()

    z: 1
    solid: true
    color: "transparent"
    width: btnSize
    height: 414

    enter: Transition {
        ScriptAction {
            script: {
                // reset position
                const duration = mainMenu.highlightMoveDuration;
                mainMenu.highlightMoveDuration = 0;
                mainMenu.currentIndex = 0;
                mainMenu.highlightMoveDuration = duration;
                mainMenuTranslate.y = 0;

                fadeInAnimationStarted();
            }
        }
        NumberAnimation { target: mainView; property: "opacity"; duration: 600; from: 0; to: 1 }
    }

    exit: Transition {
        ScriptAction {
            script: {
                if (currentChecked) {
                    currentChecked.checked = false;
                    currentChecked = null;
                }
            }
        }
        SequentialAnimation {
            ParallelAnimation {
                NumberAnimation { target: mainView; property: "opacity"; duration: 400; from: 1; to: 0 }
                NumberAnimation {
                    target: mainMenuTranslate
                    property: "y"
                    duration: 400
                    to: -mainMenu.height
                    easing.type: Easing.OutQuad
                }
            }
            PropertyAction { target: mainView; property: "visible"; value: false }
        }
    }

    PanelView {
        id: panelView
        x: mainView.x - width - 1
        y: mainView.y + mainView.paddingTop + btnHalfSize - 215
    }

    IndicatorView {
        id: indicatorView
        x: mainView.x + mainView.width + 4
        y: mainView.y + mainView.paddingTop + btnHalfSize - height / 2
    }

    Item {
        anchors.fill: parent

        layer {
            enabled: true
            effect: OpacityMask {
                maskSource: Image {
                    source: currentChecked ? "../Images/background/btn-mask-checked.png" :
                                             "../Images/background/btn-mask.png"
                }
            }
        }

        PathView {
            id: mainMenu
            anchors.fill: parent

            pathItemCount: 7
//            cacheItemCount: pathItemCount + 1
            snapMode: snapItems ? PathView.SnapOneItem : PathView.NoSnap
            highlightMoveDuration: 250

            onMovementStarted: if (currentChecked) currentChecked.checked = false

            model: launcher.rootItem.items
            delegate: MainButton {
                id: button

                iconConfiguration: modelData.icon
                transform: inAnimation.running ? aniTranslate : snapItems ? snapTranslate : null

                background.opacity: currentChecked && !checked ? 0.5 : 1.0

                Translate {
                    id: snapTranslate
                    y: -(button.y - paddingTop) % (btnSize + btnMargin)
                }

                Translate { id: aniTranslate }

                SequentialAnimation {
                    id: inAnimation

                    PropertyAction {
                        target: aniTranslate
                        property: "y"
                        value: -button.y - button.height
                    }
                    PauseAnimation { duration: Math.max((Math.min(visibleCount, 5) - index) * 100, 0) }
                    NumberAnimation {
                        target: aniTranslate
                        property: "y"
                        to: 0
                        duration: 200
                        easing.type: Easing.OutQuart
                    }

                    onFinished: {
                        if (index === 0) {
                            if (modelData.items && (mainView.opened || mainView.enter.running))
                                button.checked = true;
                        }
                    }
                }

                Connections {
                    target: mainView
                    onFadeInAnimationStarted: {
                        if (index < mainMenu.pathItemCount)
                            inAnimation.restart();
                    }
                    onExposedChanged: {
                        // unload sub menu
                        if (!mainView.exposed)
                            menuLoader.active = false;
                    }
                }

                Loader {
                    id: menuLoader

                    active: false
                    sourceComponent: MenuView {
                        parentMenu: mainView
                        parentItem: modelData

                        x: mainView.x + mainView.width + 10
                        y: mainView.y + mainView.paddingTop + btnHalfSize - height / 2
                    }
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

                            // reload sub-folder items
                            if (modelData.type === NVG.MenuSettings.FolderItem)
                                modelData.items.reload();
                            
                            // BUG: unexpected scrolling direction when dragging
                            // with PathView.movementDirection === PathView.Positive
                            mainMenu.movementDirection = PathView.Positive;
                            mainMenu.currentIndex = index;
                            mainMenu.movementDirection = PathView.Shortest;

                            menuLoader.active = true;
                            menuLoader.item.showMenu();
                            indicatorView.target = menuLoader.item;
                            panelView.target = modelData;
                        } else {
                            checked = false;
                            actionSource.trigger(button);
                        }
                    } else {
                        if (currentChecked === button) {
                            panelView.target = null;
                            indicatorView.target = null;
                            currentChecked = null;
                        }
                        if (menuLoader.item)
                            menuLoader.item.hideMenu();
                    }
                }

                PathView.onIsCurrentItemChanged: {
                    if (!PathView.isCurrentItem) {
                        checked = false;
                    }
                }
            }

            path: Path {
                startX: btnHalfSize
                startY: paddingTop + btnHalfSize
                PathLine {
                    relativeX: 0
                    relativeY: contentHeight + btnMargin
                }
            }

            transform: Translate { id: mainMenuTranslate }
        }
    }
}
