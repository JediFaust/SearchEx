import QtQuick
import Qt.labs.qmlmodels

Window {
    id: root
    width: Screen.width
    height: Screen.height
    visible: true
    title: "Search Ex"

    readonly property string endpoint: "https://serpapi.com/search?q="
    readonly property string apiKey: "59511352e8ada643cd9763fd135b431fb25e4a810de2e1f0661d27c4226eb81d"

    ListModel {
        id: results
        ListElement { type: "suggestion"; title: "Loading..." }
    }

    function customGetRequest(query, callBack) {
        const xhr = new XMLHttpRequest()

        xhr.onreadystatechange = function() {
                if (xhr.readyState === XMLHttpRequest.DONE && xhr.status === 200) {
                    let response = JSON.parse(xhr.responseText)
                    callBack(response)
                    console.log(response)
                }
        };

        xhr.open("GET", query)

        xhr.send()

    }

    function requestSuggestions(query) {
            function callBack(response) {
                    results.clear()
                    for(let i = 0; i < response.suggestions.length; i++) {
                            let newItem = {}
                            newItem.type = "suggestion"
                            newItem.title = response.suggestions[i].value

                            results.append(newItem)
                    }
            }
            customGetRequest(endpoint + query + "&api_key=" + apiKey + "&engine=google_autocomplete", callBack)
    }

    function requestDetails(query) {
            function callBack(response) {
                    let newItem = {}
                    newItem.type = "detail"
                    newItem.title = response.knowledge_graph !== undefined
                        ? response.knowledge_graph.title
                        : "Loading..."
                    newItem.imgUrl = response.knowledge_graph.header_images !== undefined
                        ? response.knowledge_graph.header_images[0].image
                        : "https://anitekh.ru/wp-content/uploads/2019/10/no-image.jpg"
                    newItem.description = response.knowledge_graph.description !== undefined
                        ? response.knowledge_graph.description
                        : "Description not provided..."

                    results.clear()
                    results.append(newItem)
            }
            customGetRequest(endpoint + query + "&api_key=" + apiKey, callBack)
    }

    Rectangle {
        id: bg
        anchors.fill: parent
        color: "#cae4ff"

    states: [
        State {
            name: ""
            PropertyChanges { target: resultList; height: 250 }
            AnchorChanges { target: resultList; anchors.left: searchBar.left; anchors.right: searchBar.right }
        },
        State {
            name: "detail"
            PropertyChanges { target: resultList; height: Screen.height }
            AnchorChanges { target: resultList; anchors.left: searchPage.left; anchors.right: searchPage.right }
        }
    ]

    transitions:
        Transition {
            NumberAnimation { properties: "height,width"; easing.type: Easing.InOutQuad; duration: 500 }
            AnchorAnimation { duration: 500 }
        }

    Item {
        id: searchPage
        anchors.fill: parent
        visible: true

        Rectangle {
            id: searchBar
            anchors { top: parent.top; topMargin: 50; left: parent.left; leftMargin: 400; right: parent.right; rightMargin: 400 }
            width: 600
            height: 50
            radius: 25
            color: "#7abbff"

            Rectangle {
                id: searchInputRect
                anchors { fill: parent; margins: 15; verticalCenter: parent.verticalCenter }
                color: searchBar.color

                TextInput {
                    id: searchInput
                    anchors.fill: parent
                    focus: true
                    text: ""
                    wrapMode: TextInput.WordWrap
                    onTextChanged: if (text === "") { resultList.visible = false }
                                    else { requestSuggestions(text); resultList.visible = true }
                    Text { text: parent.text === "" ? "Input search query..." : "" }
                }
            }

            Rectangle {
                id: searchBtn
                width: 60
                height: 35
                radius: 25
                anchors { right: parent.right; rightMargin: 20; verticalCenter: parent.verticalCenter }
                color: "#feffc6"

                Text {
                    text: "Search"
                    anchors { horizontalCenter: parent.horizontalCenter; verticalCenter: parent.verticalCenter }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: { requestDetails: searchInput.text; bg.state = "detailPage" }
                    }
                }
            }
        }

    DelegateChooser {
        id: chooser
        role: "type"
        DelegateChoice {
            roleValue: "suggestion";
        Rectangle {
            width: searchPage.width
            height: 50
            color: "#b3d8ff"

            Text {
                anchors { left: parent.left; leftMargin: 10; verticalCenter: parent.verticalCenter }
                text: title
                MouseArea {
                    focus: true
                    anchors.fill: parent
                    onClicked: { requestDetails(title); bg.state = "detail" }
                }
            }
        }
    }

    DelegateChoice {
        roleValue: "detail"

        Column {
            spacing: 50

        Text { text: title; anchors.horizontalCenter: parent.horizontalCenter }

        Image { source: imgUrl; anchors.horizontalCenter: parent.horizontalCenter }

        Text {
            text: description
            width: root.width - 100
            wrapMode: Text.WordWrap
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Rectangle {
            width: 100
            height: 50
            radius: 10
            color: searchBtn.color
            anchors.horizontalCenter: parent.horizontalCenter

            Text { anchors.centerIn: parent; text: "Go back" }
            MouseArea {
                anchors.fill: parent
                onClicked: { requestSuggestions(searchInput.text); bg.state = "" }
            }
        }
    }
    }
    }

        ListView {
            id: resultList
            visible: false
            clip: true
            height: 250
            anchors { top: searchBar.bottom; left: searchBar.left; leftMargin: 20; right: searchBar.right; rightMargin: 20 }

            model: results
            delegate: chooser
        }
    }
    }
}
