.pragma library

// If true, will display a red square in the lower right border to toggle a debug console
var DEBUG = true
// The number of lines that will be displayd in the debug console
const MAX_DEBUG_LINES = 13
// This url MUST but http. https is not supported by the javascript engine
const url = "http://127.0.0.1:8080" // You may change this to any other url that returns "buttons", "badges", "switches" and "images" in the expected format
// By default, return to the main page when the intercom screen turns off
var returnToHomePage = true

var connections = []
var debuglines = []

function loadData(debugItem, status, badgesItem, switchesItem, buttonsItem, imagesItem, badgeTimer, time, global) {
    time.text = date()
    get(debugItem, status, url + "/homeassistant?raw=true&items=buttons,badges,switches,images", function (data) {
        returnToHomePage = !data["preventReturnToHomepage"]
        badgeTimer.interval = data["refreshInterval"] || 2000
        var dataItem = data["data"]
        buttonsItem.model = dataItem["buttons"] || []
        badgesItem.model = dataItem["badges"] || []
        switchesItem.model = dataItem["switches"] || []
        var images = dataItem["images"] || []
        var i = images.length
        while (i--) {
            if (images[i].source.indexOf("?") > 0) {
                images[i].source += "&time=" + Date.now()
            } else {
                images[i].source += "?time=" + Date.now()
            }
        }
        imagesItem.model = images
        debug(debugItem, imagesItem.data.length)
    })
}

function handleScreenOff() {
    return !returnToHomePage
}

function get(debugItem, status, url, callback) {
    var i = connections.length;
    while (i--) {
        if (Date.now() - connections[i].startTime > 2000) {
            if (connections[i].readyState < 4) {
                // Not sure if this works, but at least we try
                debug(debugItem, "Calling abort")
                connections[i].abort()
            }
            connections.splice(i, 1)
        }
    }
    var xhr = new XMLHttpRequest();
    connections.push(xhr)
    xhr.startTime = Date.now()
    xhr.onreadystatechange = function (e) {
        if (xhr.readyState == 4) {
            debug(debugItem, "readyState: " + xhr.readyState + " / status: " + xhr.status)
            if (xhr.status == 200) {
                status.text = "API Connected"
                status.color = "green"
                var data = JSON.parse(xhr.responseText)
                callback(data)
            } else {
                status.text = "API error: " + xhr.status
                status.color = "red"
                callback([])
            }
        } else {
            //debug(debugItem, "readyState: " + xhr.readyState)
        }
    };
    xhr.open('GET', url)
    xhr.send();
}

function toggle(debugItem, status, modelData) {
    debug(debugItem, "toggle: " + modelData.name)
    get(debugItem, status, url + "/homeassistant?raw=true&entities=" + modelData.entity_id + "&domain=" + modelData.domain + "&service=toggle", function (xhr) {
    })
}

function debug(debugItem, text) {
    if (DEBUG) {
        if (debuglines.length >= MAX_DEBUG_LINES) {
            debuglines.shift()
        }
        debuglines.push(date() + " " + text)
        debugItem.text = debuglines.join("\n")
    }
}

function date() {
    const d = new Date()
    return d.toISOString().split('T')[0] + " " + d.toLocaleTimeString();
}

function showDebugConsole() {
    return DEBUG
}
