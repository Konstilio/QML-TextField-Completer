import QtQuick 2.10
import QtQuick.Window 2.10

Window {
    visible: true
    width: 640
    height: 480
    title: qsTr("Hello World")

    TextFieldWithCompleter {
        anchors.top:parent.top
        anchors.left:parent.left
        anchors.right:parent.right
        height:30

        completerModel: SuggestionsModel
        popupWidth: Math.min(300, width)
    }
}
