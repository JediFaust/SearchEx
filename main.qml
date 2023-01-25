import QtQuick

Window {
    id: root
    width: Screen.width
    height: Screen.height
    visible: true
    title: "Search Ex"

    readonly property string bgColor: "#cae4ff"
    readonly property string btnColor: "#feffc6"
    readonly property string barColor: "#7abbff"
    readonly property string itemColor: "#b3d8ff"
    readonly property string inputColor: "purple"

    property int barHeight: 50
    property int barWidth: 600
    property int inputWidth: 200
    property int defMargin: 10

    readonly property string endpoint: "https://serpapi.com/search?q="
    readonly property string apiKey: "59511352e8ada643cd9763fd135b431fb25e4a810de2e1f0661d27c4226eb81d"

    onWidthChanged: {
        if (root.width + 30 < 600) barWidth = root.width - 30
    }


    ListModel {
        id: results
        ListElement { title: "Loading..." }
    }

    ListModel {
        id: detail
        ListElement { title: "Loading..."; imgUrl: "qrc:/loader.gif"; description: "Description is loading..." }
    }

    function requestSuggestions(query) {
          const data = null;

          const xhr = new XMLHttpRequest();

          xhr.onreadystatechange = function () {
              if (xhr.readyState === XMLHttpRequest.DONE) {
                    let response = JSON.parse(xhr.responseText)

                    results.clear()
                    for(let i = 0; i < response.suggestions.length; i++) {
                            let newItem = {}
                            newItem.title = response.suggestions[i].value

                            results.append(newItem)
                        }
              }
          };

            xhr.open("GET", endpoint + query + "&api_key=" + apiKey + "&engine=google_autocomplete")

            xhr.send(data);
    }
    function requestDetails(query) {
          const data = null;

          const xhr = new XMLHttpRequest();
            console.log(query)

          xhr.onreadystatechange = function () {
              if (xhr.readyState === XMLHttpRequest.DONE) {
                    let response = JSON.parse(xhr.responseText)

                    let newItem = {}
                    newItem.title = response.knowledge_graph.title
                    newItem.imgUrl = response.knowledge_graph.header_images !== undefined
                        ? response.knowledge_graph.header_images[0].image
                        : "https://anitekh.ru/wp-content/uploads/2019/10/no-image.jpg"
                    newItem.description = response.knowledge_graph.description

                    detail.clear()
                    detail.append(newItem)
              }
          };

            xhr.open("GET", endpoint + query + "&api_key=" + apiKey);

            xhr.send(data);
    }

    Rectangle {
        id: bg
        anchors.fill: parent
        color: bgColor

    states: [
        State {
            name: ""
            PropertyChanges { target: searchPage; visible: true }
            PropertyChanges { target: detailPage; visible: false }
        },
        State {
            name: "detailPage"
            PropertyChanges { target: searchPage; visible: false }
            PropertyChanges { target: detailPage; visible: true }
        }
    ]

    Item {
        id: searchPage
        anchors.fill: parent
        visible: true

        Rectangle {
            id: searchBar
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: defMargin * 5
            width: barWidth
            height: barHeight
            radius: barWidth / 2
            color: barColor

            Rectangle {
                id: searchInputRect
                anchors.verticalCenter: parent.verticalCenter
                anchors.fill: parent
                anchors.margins: defMargin * 1.5
                color: barColor

                TextInput {
                    id: searchInput
                    anchors.fill: parent
                    focus: true
                    text: "Input search query..."
                    wrapMode: TextInput.WordWrap
                    onTextChanged: {
                                if (text === undefined)
                                    resultList.visible = false
                                else {
                                    requestSuggestions(text)
                                    resultList.visible = true
                                }
                           }
                }
            }

            Rectangle {
                width: barHeight + defMargin
                height: barHeight - defMargin * 1.5
                radius: barHeight / 2
                anchors.right: parent.right
                anchors.rightMargin: defMargin * 2
                anchors.verticalCenter: parent.verticalCenter
                color: btnColor

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

        ListView {
            id: resultList
            visible: false
            clip: true
            height: barHeight * 5
            anchors.top: searchBar.bottom
            anchors.left: searchBar.left
            anchors.leftMargin: defMargin * 2
            anchors.right: searchBar.right
            anchors.rightMargin: defMargin * 2

            model: results
            delegate: Rectangle {
                width: searchPage.width
                height: barHeight
                color: itemColor

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.leftMargin: defMargin
                    text: title
                    MouseArea {
                        focus: true
                        anchors.fill: parent
                        onClicked: {
                            // Change page and make details request
                            requestDetails(title)
                            bg.state = "detailPage"
                        }
                    }
                }
            }
        }
        }

    Item {
        id: detailPage
        anchors.fill: parent
        visible: false

        ListView {
            id: detailList
            anchors.fill: parent
            anchors.margins: defMargin * 2
            model: detail
            delegate: Column {
                spacing: barHeight
                anchors.horizontalCenter: parent.horizontalCenter

                Text { text: title; anchors.horizontalCenter: parent.horizontalCenter }

                Image {
                    source: imgUrl
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Text {
                    text: description
                    width: root.width - defMargin * 10
                    wrapMode: Text.Wrap
                    anchors.horizontalCenter: parent.horizontalCenter
                }

                Rectangle {
                    width: barHeight * 2
                    height: barHeight
                    radius: 10
                    color: btnColor
                    anchors.horizontalCenter: parent.horizontalCenter

                    Text { anchors.centerIn: parent; text: "Go back" }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: bg.state = ""
                    }
                }
            }
        }
        }
    }
}



