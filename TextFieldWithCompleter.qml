import QtQuick 2.0
import QtQuick.Controls 2.3


TextField {
    id: _textFieldWithCompleterRoot
    property var completerModel // model of completer, works with Display Role so far
    property int popupPadding: 0 // padding of completer popup
    property string endOfWord: "~!#$%^&*()_+{}|:\"<>?,./;'[]\\-=\n " // all characters that represents end of word

    signal textModified(); // This signal is emitted whenever the text is edited. Or changed because of completer selection.
    signal completerPrefixChanged(var prefixText); // This signal is emitted when completer prefix is changed, before invoking the popup. This is good place to filter the model according to prefixText.

    property Component completerRowDelegate : MenuItem {
        text: rowText
        width: contentWidth
        background: Rectangle {
            color : (pressed ? _privatePallete.mid : (bCurrentRow ? _privatePallete.highlight : _privatePallete.window))
        }

        onTriggered: {
            _textFieldWithCompleterRoot.complete(text);
        }
    }

    property Component completerBackgroundDelegate: Rectangle {
        border.width: _textFieldWithCompleterRoot.popupPadding
        color: _privatePallete.window
        border.color: "black"
        height: contentHeight
        width: contentWidth
    }

    QtObject {
        id: _private
        property var popupWindow: null
        property int startPos: -1
    }

    Text {
        id: _privateMetrics
        visible: false
        font: _textFieldWithCompleterRoot.font
    }

    SystemPalette {
        id: _privatePallete
        colorGroup: SystemPalette.Active
    }

    Keys.onUpPressed: {
        if (!_private.popupWindow || !_private.popupWindow.visible)
            return;

        _private.popupWindow.decreaseIndex();
    }

    Keys.onDownPressed: {
        if (!_private.popupWindow || !_private.popupWindow.visible)
            return;

        _private.popupWindow.increaseIndex();
    }

    Keys.onReturnPressed: {
        if (!_private.popupWindow || !_private.popupWindow.visible)
            return;

        _private.popupWindow.selectIndex();
    }

    Component {
        id: _completer

        Menu {
            id: _completerMenu
            property var menuModel
            property var modelDelegate
            padding: _textFieldWithCompleterRoot.popupPadding
            contentItem: ListView {
                id: _contentItem
                model: _completerMenu.menuModel
                width: contentWidth
                height: contentHeight

                delegate: Loader {
                    property var rowText: model.display
                    property int rowIndex: model.index
                    property bool  bCurrentRow: rowIndex == _contentItem.currentIndex
                    property int contentWidth: _contentItem.width
                    sourceComponent: _textFieldWithCompleterRoot.completerRowDelegate
                }
            }

            background: Loader {
                property int contentHeight: _contentItem.contentHeight
                property int contentWidth: _contentItem.width
                sourceComponent: _textFieldWithCompleterRoot.completerBackgroundDelegate
            }

            function increaseIndex() {
                _contentItem.incrementCurrentIndex();
            }

            function decreaseIndex() {
                _contentItem.decrementCurrentIndex();
            }

            function selectIndex() {
                _textFieldWithCompleterRoot.complete(menuModel.data(menuModel.index(_contentItem.currentIndex, 0), 0));
            }
        }
    }

    onTextEdited: {
        var filterText = getWord(text, cursorPosition);

        _textFieldWithCompleterRoot.textModified();
        _textFieldWithCompleterRoot.completerPrefixChanged(filterText);

        if (_private.popupWindow)
        {
            if (completerModel.rowCount() === 0 || filterText.length < 2)
            {
                _private.popupWindow.close();
                return
            }
            else
            {
                _privateMetrics.text = text.substring(0, _private.startPos);
                _private.popupWindow.popup(parent,
                    Qt.point(_textFieldWithCompleterRoot.x + _textFieldWithCompleterRoot.leftPadding + _privateMetrics.implicitWidth, _textFieldWithCompleterRoot.height));
                _textFieldWithCompleterRoot.forceActiveFocus();
            }
        }
    }

    onCompleterModelChanged: {
        if (_private.popupWindow)
            return;

        _private.popupWindow =
            _completer.createObject(_textFieldWithCompleterRoot,
            {
                "menuModel" : completerModel
            });
    }

    function complete(completeText)
    {
        if (_private.startPos == -1 || _private.startPos >= text.length)
            return;

        var oldText = _textFieldWithCompleterRoot.text;
        _textFieldWithCompleterRoot.text = oldText.substring(0, _private.startPos) + completeText + oldText.substring(cursorPosition, oldText.length) + ' '
        _textFieldWithCompleterRoot.cursorPosition = _private.startPos + completeText.length + 1 // set cursor position
        _private.startPos = -1
        _textFieldWithCompleterRoot.textModified();

        if (_private.popupWindow)
            _private.popupWindow.close();
    }

    function getWord(text, position)
    {
         _private.startPos = -1;
        if (position > text.length)
            return "";

        var iPos = position - 1;
        for (; iPos >= 0; --iPos)
        {
            if (endOfWord.indexOf(text.charAt(iPos)) > -1)
            {
                break;
            }
        }
        iPos += 1;

        if (iPos >= position)
            return "";

        _private.startPos = iPos;
        return text.substring(iPos, position);
    }
}
