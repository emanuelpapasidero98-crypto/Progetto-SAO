import QtQuick 2.12
import QtQuick.Controls 2.12

import NERvGear.Controls 1.0
import NERvGear.Private 1.0 as NVG

import "."

Control {
    id: thiz

    readonly property alias textEdit: textEdit
    readonly property bool hasToolBar: textEdit.activeFocus &&
                                       textEdit.textFormat === TextEdit.RichText

    function checkModified() {
        return NoteToolBar.documentHandler.checkModified(textEdit.textDocument);
    }

    function extractText() {
        return textEdit.textFormat ?
                    NoteToolBar.documentHandler.extractRichText(textEdit.textDocument) :
                    NoteToolBar.documentHandler.extractPlainText(textEdit.textDocument);
    }

    onHasToolBarChanged: if (hasToolBar) NoteToolBar.parent = thiz

    clip: true
    bottomPadding: hasToolBar ? NoteToolBar.height : 0

    contentItem: Flickable {
        id: scrollView

        clip: true
        contentWidth: width
        contentHeight: textEdit.height

        ScrollBar.vertical: ScrollBar { }

        TextEdit {
            id: textEdit
            width: scrollView.width
            height: Math.max(implicitHeight, scrollView.height)
            font: thiz.font
            selectionColor: thiz.Style.accentColor
            selectedTextColor: thiz.Style.primaryHighlightedTextColor
            selectByMouse: true
            textFormat: TextEdit.RichText
            wrapMode: TextEdit.Wrap
            antialiasingMode: 0 // GrayAntialiasing
            padding: 8
            topPadding: 0
            rightPadding: 16

            Keys.onEscapePressed: focus = false
        }
    }
}
