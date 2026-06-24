import QtQuick 2.12

import NERvGear 1.0 as NVG

MouseArea {
    id: thiz

    readonly property bool checked: ctx_widget.editing && ctx_widget.currentIndex === index
    readonly property alias hovered: thiz.containsMouse
    readonly property alias progress: output.result

    property int index: -1

    property NVG.SettingsMap settings

    hoverEnabled: true
    propagateComposedEvents: true
    acceptedButtons: Qt.LeftButton | Qt.RightButton

    onPressed: {
        if (mouse.button === Qt.LeftButton)
            NVG.SystemCall.playSound(NVG.SFX.FeedbackClick);
    }

    onClicked: {
        ctx_widget.currentIndex = index;

        if (mouse.button === Qt.LeftButton) {
            if (!ctx_widget.editing) {
                if (actionSource.configuration)
                    actionSource.trigger(this);
            }
        } else {
            mouse.accepted = ctx_widget.editing;
        }
    }

    NVG.DataSource { id: dataSource; configuration: settings.data }

    NVG.DataSourceProgressOutput { id: output; source: dataSource }

    NVG.ActionSource { id: actionSource; text: settings.label || this.title; configuration: settings.action }
}
