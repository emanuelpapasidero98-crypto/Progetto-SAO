import QtQuick 2.12

import NERvGear 1.0 as NVG
import NERvGear.Private 1.0 as NVG
import NERvGear.Templates 1.0 as T

NVG.Container {

    property Item parent: ctx_widget
    property bool visible: false
    property int style: T.Theme.System

    property Component iconPreview // NERvGear.Templates.Preview
    property alias iconPreviewDefaultIcon: iconStorage.value
    property NVG.ResourceFilter iconAvailableFilter
    property NVG.ResourceFilter iconPreferableFilter

    signal open
    signal close

    NVG.ControlStatesStorage { id: iconStorage }
}
