import QtQuick 2.0
import QtQuick.Controls 2.3


TextField {
    id: _textFieldWithCompleterRoot
    property var completerModel // model of completer, works with Display Role so far
    property int popupWidth: width // width of completer popup
    property int popupPadding: 2 // padding of completer popup
    property string endOfWord: "~!#$%^&*()_+{}|:\"<>?,./;'[]\\-=\n " // all characters that represents end of word

    property Component completerDelegate : MenuItem {
        text: itemName
        width: contentWidth
        background: Rectangle {
            color : (pressed ? "lightblue" : (bCurrentItem ? "blue" : "white"))
        }

        onTriggered: {
            _textFieldWithCompleterRoot.complete(text);
        }
    }

    property Component completerBackgroundDelegate: Rectangle {
        border.width: _textFieldWithCompleterRoot.popupPadding
        color: "white"
        border.color: "black"
        height: contentHeight
        width: contentWidth
    }

    QtObject {
        id: _private
        property var popupWindow: null
        property int startPos: -1
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
            width:_textFieldWithCompleterRoot.popupWidth
            property var menuModel
            property var modelDelegate
            padding: _textFieldWithCompleterRoot.popupPadding
            contentItem: ListView {
                id: _contentItem
                model: _completerMenu.menuModel
                width:_textFieldWithCompleterRoot.popupWidth

                delegate: Loader {
                    property var itemName: model.display
                    property int itemIndex: model.index
                    property bool  bCurrentItem: itemIndex == _contentItem.currentIndex
                    property int contentWidth: _contentItem.width
                    sourceComponent: _textFieldWithCompleterRoot.completerDelegate
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
        console.log("filterText = " + filterText);
        if (_private.popupWindow)
        {
            completerModel.setFilterWildcard(filterText + '*');
            if (completerModel.rowCount() === 0 || filterText.length < 2)
            {
                _private.popupWindow.close();
                return
            }
            else
            {
                _private.popupWindow.popup(parent, Qt.point(_textFieldWithCompleterRoot.x, _textFieldWithCompleterRoot.height));
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

        console.log("completeText = " + completeText + " pos = " + _private.startPos)
        var oldText = _textFieldWithCompleterRoot.text;
        _textFieldWithCompleterRoot.text = oldText.substring(0, _private.startPos) + completeText + oldText.substring(cursorPosition, oldText.length) + ' '
        _textFieldWithCompleterRoot.cursorPosition = _private.startPos + completeText.length + 1 // set cursor position
        _private.startPos = -1

        if (_private.popupWindow)
            _private.popupWindow.close();
    }

    function getWord(text, position)
    {
         _private.startPos = -1;
        console.log("getWord position: " + position)
        if (position > text.length)
            return "";

        var iPos = position - 1;
        for (; iPos >= 0; --iPos)
        {
            if (endOfWord.indexOf(text.charAt(iPos)) > -1)
            {
                console.log("getWord endOfWord: " + text.charAt(iPos))
                break;
            }
        }
        iPos += 1;

        if (iPos >= position)
            return "";

        console.log("getWord iPos: " + iPos)
        _private.startPos = iPos;
        return text.substring(iPos, position);
    }
}
