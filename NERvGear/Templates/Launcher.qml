import QtQuick 2.12

import NERvGear 1.0 as NVG

NVG.Container {

    /*readonly*/property QtObject geometry
    /*readonly*/property QtObject rootItem

    property LauncherView view
    property int style: Theme.System

    property Component preference // NERvGear.Preferences.ObjectGroupPreference
    property Component itemOptions // NERvGear.Templates.LauncherItemOptions

    signal aboutToShow(var alignment, var mouse)
    signal aboutToHide()

    signal opened()
    signal closed()
}
