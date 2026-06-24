import QtQuick 2.12

import NERvGear 1.0 as NVG

Grid {
    // NOTE: only 0 or 1 supported currently
    property int secondaryData: 0

    property NVG.ResourceFilter iconAvailableFilter
    property NVG.ResourceFilter iconPreferableFilter

    columns: 1
    flow: Grid.TopToBottom
}
