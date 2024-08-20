import QtQuick 1.1
import Components 1.0
import Components.Styles 1.0
import BtObjects 2.0
import "js/ha.js" as Utils

Page {
    id: page
    showBackButton: true
    onBackClicked: tabView.activateTab(homePage)
    headerLabel: "HomeAssistant" + trsl.empty

    function aboutToShow() {
	    Utils.loadData(debug, status, badges, switches, buttons, images, badgeTimer, time, global)
        badgeTimer.start()
    }

    function handleScreenOff() {
        var shouldReturn = Utils.handleScreenOff()
	    if(!shouldReturn) {
            badgeTimer.stop()
	    }
	    return shouldReturn;
    }

    Column {
	    id: column
        anchors.top: backButton.bottom
	    anchors.left: parent.left
	    anchors.right: parent.right
        Flow {
            anchors.left: parent.left
	        anchors.right: parent.right
            Repeater {
                id: badges
                Rectangle {
                    width: 100; height: 50
                    border.width: 1
                    color: "grey"
                    UbuntuLightText {
                        font.pixelSize: 20
                        color: "white"
                        text: modelData.state
                        anchors {
                            top: parent.top
                            topMargin: 3
                            left: parent.left
                            leftMargin: 3
                        }
                    }
                }
            }
        }
        Flow {
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: 5
            Repeater {
                id: images
                Image {
                    cache: false
                    visible: true
		            width: modelData.width
		            height: modelData.height
                    source: modelData.source
                }
            }
        }
        Flow {
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: 5
            Repeater {
                id: switches
                Item {
                    width: 200; height: 50
                    UbuntuLightText {
                        font.pixelSize: 18
                	    width: 50
                        color: "white"
                        text: modelData.name
                        anchors {
                            top: parent.top
                            topMargin: 3
                            left: parent.left
                            leftMargin: 3
                        }
                    }
                    BasicButton {
                        anchors {
                            top: parent.top
                            topMargin: 3
                            right: parent.right
                            rightMargin: 3
                        }
                        checkable: true
                        checked: modelData.state
                        style: CheckableButtonStyle {
                            defaultImage: "images/ringtones/switch-bg_btn.svg"
                            checkedImage: "images/ringtones/switch-bg_btn_p.svg"
                            defaultIconLeft: "images/ringtones/switch_btn.svg"
                            defaultIconRight: "images/ringtones/disable_icon.svg"
                            checkedIconLeft: "images/ringtones/enable_icon.svg"
                            checkedIconRight: "images/ringtones/switch_btn_p.svg"
                        }
                        onTouched: {
				            Utils.toggle(debug, status, modelData)
			            }
                    }
                }
            }
        }
        Flow {
            anchors.left: parent.left
            anchors.right: parent.right
            spacing: 13
            Repeater {
                id: buttons
                BasicButton {
                    style: LabelStyle {
                        defaultImage: "images/first_configuration/list_btn.svg"
                        pressedImage: "images/first_configuration/list_btn_p.svg"
                        description: modelData.name + trsl.empty
                    }
                    onTouched: {
                        Utils.toggle(debug, status, modelData)
                    }
                }
            }
        }
    }

    Item {
        Timer {
            id: badgeTimer
            interval: 2000; running: true; repeat: true
            onTriggered: {
		        Utils.loadData(debug, status, badges, switches, buttons, images, badgeTimer, time, global)
            }
        }

        UbuntuLightText {
            id: status
	        text: ""
            color: "white"
            font.pixelSize: 16
            anchors.left: parent.left
            anchors.leftMargin: 10
        }
    
        UbuntuLightText {
            id: time
            color: "white"
            font.pixelSize: 18
            anchors.left: parent.left
            anchors.leftMargin: (page.width / 2) + 220
        }
    }

    Rectangle {
        width: 300
        height: 200
        color: "black"
        id: debugContainer
        visible: false
        anchors.bottom: debugButton.top
        anchors.left: page.left
        anchors.right: page.right
        Text {
	        z: 1
            id: debug
            text: "// debug console"
            color: "white"
            font.pixelSize: 12
            anchors.left: parent.left
            anchors.leftMargin: 3
        }      
        MouseArea {
            anchors.fill: parent
            onClicked: {
                rect.color = "blue"
            }
        }  
    }

    Rectangle {
        width: 30
        height: 30
        color: "red"
        id: debugButton
	    visible: Utils.showDebugConsole()
         
        anchors.bottom: page.bottom
        anchors.right: page.right
        Text {
	        z: 1
            text: "D"
            color: "black"
            font.pixelSize: 18
            font.bold: true
            anchors.left: parent.left
            anchors.leftMargin: 3
        }      
        MouseArea {
            anchors.fill: parent
            onClicked: {
                console.log("foo: " + debugContainer.visible)
                debugContainer.visible = !debugContainer.visible
            }
        }   
    }
}

