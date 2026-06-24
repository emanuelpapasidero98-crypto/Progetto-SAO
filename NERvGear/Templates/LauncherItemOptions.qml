import QtQml 2.12

import NERvGear 1.0 as NVG
import NERvGear.Private 1.0 as NVG

NVG.Container {

    property Component iconPreview // NERvGear.Templates.Preview
    property alias iconPreviewDefaultIcon: iconStorage.value
    property NVG.ResourceFilter iconAvailableFilter
    property NVG.ResourceFilter iconPreferableFilter

    property Component itemPreview // NERvGear.Templates.Preview
    property Component itemPreference // NERvGear.Preferences.ObjectGroupPreference

    NVG.ControlStatesStorage { id: iconStorage }
}
