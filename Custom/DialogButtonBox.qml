import QtQuick 2.12
import QtQuick.Controls.Material 2.4

import NERvGear.Controls 1.0

import "../Material" as C

C.DialogButtonBox {
    id: control

    background: null
    alignment: position === DialogButtonBox.Footer ? Qt.AlignHCenter : Qt.AlignRight

    delegate: Button {
        flat: !highlighted && position === DialogButtonBox.Header
        highlighted : {
            switch (C.DialogButtonBox.buttonRole) {
            case C.DialogButtonBox.AcceptRole:
            case C.DialogButtonBox.ActionRole:
            case C.DialogButtonBox.YesRole:
            case C.DialogButtonBox.ApplyRole: return true;
            }
            return false;
        }

        background.implicitWidth: 64
    }
}
