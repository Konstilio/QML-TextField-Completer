# QML-TextField-Completer
TextFieldWithCompleter.qml implements QML Text Field with Completer that could be customized.

/*
    TextFieldWithCompleter is derived from TextField, so you could use all it's properties in TextFieldWithCompleter.

    Added properties:
        @completerModel: model of completer, works with Display Role so far
        @popupPadding: padding of completer popup
        @endOfWord: all characters that represents end of word (Needed for popping up the completer)

        @completerRowDelegate: delegate for customizing completer row
            Attached properties:
                @rowText: Reffers to display Role of completerModel

                @rowIndex Current index in completerModel

                @bCurrentRow True, if row is current row of Completer popup

        @completerBackgroundDelegate: delegate that customizing completer background
            Attached properties:
                @contentHeight: Height of popup content
                @contentWidth: Width of popup content

      Signals:
        @textModified(); // This signal is emitted whenever the text is edited. Or changed because of completer selection.
        @completerPrefixChanged(var prefixText); // This signal is emitted when completer prefix is changed, before invoking the popup.
            This is good place to filter the model according to prefixText.

      Functions:
        @complete(var text); // Completes textField with the text.


*/

Example of usage:
```
TextFieldWithCompleter {
    id: _textField
    anchors.top:parent.top
    anchors.left:parent.left
    anchors.right:parent.right
    height:30

    completerModel: SuggestionsModel
    popupPadding: 1

    onTextModified: {
        console.log("modified")
    }

    onCompleterPrefixChanged: {
        completerModel.setFilterWildcard(prefixText + '*');
    }

    // Delegate for the row in popup model
    completerRowDelegate : MenuItem {
        text: rowText
        width: 300
        background: Rectangle {
            color : (pressed ? "green" : (bCurrentRow ? "lightblue" : "white"))
        }

        onTriggered: {
            _textField.complete(text);
        }
    }

    // Delegate for popup background
    completerBackgroundDelegate: Rectangle {
        border.width: 1
        color: "white"
        border.color: "black"
        height: contentHeight
        width: 300 + 2
    }
}
```
