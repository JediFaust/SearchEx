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

    // make translations on page swap

    ListModel {
        id: results
        ListElement { type: "suggestion"; title: "Loading..." }
        ListElement { type: "detail"; title: "Loading..."; imgUrl: "qrc:/loader.gif"; description: "Description is loading..." }
    }

    function customGetRequest(query, callBack) {
        const xhr = new XMLHttpRequest()

        xhr.onreadystatechange = function() { callBack(xhr) };

        xhr.open("GET", query)

        xhr.send()

    }

    function requestSuggestions(query) {
            function callBack(xhr) {
                if (xhr.readyState === XMLHttpRequest.DONE && xhr.status === 200) {
                    let response = JSON.parse(xhr.responseText)

                    results.clear()
                    for(let i = 0; i < response.suggestions.length; i++) {
                            let newItem = {}
                            newItem.type = "suggestion"
                            newItem.title = response.suggestions[i].value

                            results.append(newItem)
                    }
                }
            }
            customGetRequest(endpoint + query + "&api_key=" + apiKey + "&engine=google_autocomplete", callBack)
    }

    function requestDetails(query) {
            function callBack(xhr) {
                if (xhr.readyState === XMLHttpRequest.DONE && xhr.status === 200) {
                    let response = JSON.parse(xhr.responseText)

                    let newItem = {}
                    newItem.type = "detail"
                    newItem.title = response.knowledge_graph.title !== undefined
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
            PropertyChanges {
                target: resultList; height: searchBar.height * 5
            }
            AnchorChanges {
                target: resultList
                anchors.left: searchBar.left; anchors.right: searchBar.right
            }
        },
        State {
            name: "detail"
            PropertyChanges {
                target: resultList; height: Screen.height
            }
            AnchorChanges {
                target: resultList
                anchors.left: searchPage.left; anchors.right: searchPage.right
            }
        }
    ]

    transitions: [
        Transition {
            from: ""; to: "detail"
            NumberAnimation {
                target: resultList
                properties: "height,width"
                easing.type: Easing.InOutQuad
                duration: 500
            }
            AnchorAnimation { duration: 500 }
        },
        Transition {
            from: "detail"; to: ""
            NumberAnimation {
                target: resultList
                properties: "height,width"
                easing.type: Easing.InOutQuad
                duration: 500
            }
            AnchorAnimation { duration: 500 }
        }
    ]

    Item {
        id: searchPage
        anchors.fill: parent
        visible: true

        Rectangle {
            id: searchBar
            anchors.top: parent.top
            anchors.topMargin: 50
            anchors.left: parent.left
            anchors.leftMargin: 400
            anchors.right: parent.right
            anchors.rightMargin: 400
            width: 600
            height: 50
            radius: 25
            color: "#7abbff"

            Rectangle {
                id: searchInputRect
                anchors.verticalCenter: parent.verticalCenter
                anchors.fill: parent
                anchors.margins: 15
                color: searchBar.color

                TextInput {
                    id: searchInput
                    anchors.fill: parent
                    focus: true
                    text: ""
                    wrapMode: TextInput.WordWrap
                    onTextChanged: {
                                if (text === undefined)
                                    resultList.visible = false
                                else {
                                    requestSuggestions(text)
                                    resultList.visible = true
                                }
                           }
                    Text { text: parent.text === "" ? "Input search query..." : "" }
                }
            }

            Rectangle {
                id: searchBtn
                width: searchBar.height + 10
                height: searchBar.height - 15
                radius: searchBar.height / 2
                anchors.right: parent.right
                anchors.rightMargin: 20
                anchors.verticalCenter: parent.verticalCenter
                color: "#feffc6"

                Text {
                    text: "Search"
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.verticalCenter: parent.verticalCenter

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            requestDetails: searchInput.text
                            bg.state = "detailPage"
                        }
                    }
                }
            }
        }

        // Search Results

    DelegateChooser {
        id: chooser
        role: "type"
    DelegateChoice {
            roleValue: "suggestion"; Rectangle {
            width: searchPage.width
            height: searchBar.height
            color: "#b3d8ff"

            Text {
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 10
                text: title
                MouseArea {
                    focus: true
                    anchors.fill: parent
                    onClicked: {
                        // Change page and make details request
                        requestDetails(title)
                        bg.state = "detail"
                    }
                }
            }
        }
    }

    DelegateChoice { roleValue: "detail";
        Column {
            spacing: searchBar.height
            anchors.horizontalCenter: parent.horizontalCenter

        Text { text: title; anchors.horizontalCenter: parent.horizontalCenter }

        Image {
            source: imgUrl
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Text {
            text: description
            width: root.width - 100
            wrapMode: Text.Wrap
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Rectangle {
            width: searchBar.height * 2
            height: searchBar.height
            radius: 10
            color: searchBtn.color
            anchors.horizontalCenter: parent.horizontalCenter

            Text { anchors.centerIn: parent; text: "Go back" }
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    requestSuggestions(searchInput.text)
                    bg.state = ""
                }
            }
        }
    }
            }
    }

        ListView {
            id: resultList
            visible: false
            clip: true
            height: searchBar.height * 5
            anchors.top: searchBar.bottom
            anchors.left: searchBar.left
            anchors.leftMargin: 20
            anchors.right: searchBar.right
            anchors.rightMargin: 20

            model: results
            delegate: chooser
        }
    }
}
}



