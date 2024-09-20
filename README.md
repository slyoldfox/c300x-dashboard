# c300x-dashboard

This project aims to bring some additional touch functionality to the Bticino C300X intercom in order to control other home automation devices from the GUI interface.

![image](https://github.com/user-attachments/assets/acc158c9-7ec9-429f-9f4e-07eecbf9b31a)

Bticino c100x devices are untested at this point.

The GUI on the intercom is built on Qt with QtQuick. The markup is done with the QML language.

The version of Qt is 4.8.7 and you can download the software/documentation at https://download.qt.io/archive/qt/4.8/4.8.7/

The intercom queries [c300x-controller](https://github.com/slyoldfox/c300x-controller/tree/main) for data, because the intercom can only query *http* hosts and does not handle SSL connections.
The c300-controller aggregates data gathered from different sources and serves them to the GUI.

By default, the dashboard will query `http://localhost:8080/` but you can serve your own JSON file by changing the `url` field in the `js/ha.js` file. Of course the content structure must be the same and looks like this:

```json
{
  "preventReturnToHomepage": true,    // optional
  "refreshInterval": 2000,            // optional  
  "data": {
    "pages": [
      {
        "badges": [
          {
            "state": "Garden\n21.6°C"
          },
          {
            "state": "⚡-\n0.283kW"
          },
          {
            "state": "⚡+\n0.0kW"
          },
          {
            "state": "☀️⚡\n161.64W"
          }
        ],
        "images": [
          {
            "width": 300,
            "height": 170,
            "source": "http://192.168.0.XX/some/camera.img?width=300" // Must be http !
          }
        ],
        "buttons": [
          {
            "domain": "light",
            "entity_id": "light.shelly_lamp_switch_0",
            "name": "TV"
          },
          {
            "domain": "light",
            "entity_id": "light.shelly_lamp_switch_0,light.mss425e_8575_outlet_1",
            "name": "☀️⚡ 💡 ! Living"
          },
          {
            "domain": "cover",
            "entity_id": "cover.living",
            "name": "Screen Living"
          }
        ],
        "switches": [
          {
            "entity_id": "light.shelly_lamp_switch_0",
            "domain": "light",
            "name": "TV",
            "state": false
          }
        ]
      }
    ]
  }
}
```

As you can see the page is divided into pages, each page can have 4 sections and are displayed in this order:

- Badges: these display states of an entity
- Images: displays images (for example security cameras)
- Switches: on/off switches which also hold the on/off state
- Buttons: for action buttons which don't hold an on/off state

If you omit a section, the rendering for this section will be empty. 
If you provide more than one page, a pager in the lower left bottom will be shown.

If you have HomeAssistant, you can configure c300x-controller to fetch data from there and display it on the intercom.

#### 1. Configuring c300x-controller

Make sure you have at least version *2024.8.1* and configure the `homeassistant` section in `config.json`

```json
{
  "homeassistant": {
    "preventReturnToHomepage": true,  // Not required, will keep the HomeAssistant page active, when intercom screen turns off 
    "token": "PUT_YOUR_TOKEN_HERE",   // Required, Long-lived access token from https://homeassistant/profile/security
    "url": "https://homeassistant/",  // Required, base url of your HomeAssistant endpoint
    "pages": [
      {
        "flow": {
          // This is an example for an Energy Flow card (as seen on https://github.com/flixlix/energy-flow-card-plus)
          "period": "hour", // 5minute, hour, day, week, month
          "starttime": "dayjs().startOf('day').toISOString()", // Any kind of dayjs() expression formatted in ISO format
          "endtime": "dayjs().toISOString()",
          "$color": "white",
          "$width": 800,
          "$height": 480,
          "items": [
            {
              "$textColor": "purple",
              "$textSize": 14,
              "$borderColor": "#00bcd4",
              "$leftMargin": 50,
              "$topMargin": 150,
              "$extraMargin": 30,
              "formula": "($(sensor.energy_production_tarif_1).statistics.sum + $(sensor.energy_production_tarif_2).statistics.sum).toFixed(1)",
              "state": ["⚡+", "f:state", "kWh"],
              "lines": [
                // You are responsible for drawing the lines between the items
                { "startX": 150, "startY": 200, "endX": 450, "endY": 200, "color": "#00bcd4" }
              ]
            },
            {
              "$textColor": "#00bcd4",
              "$textSize": 14,
              "$borderColor": "#00bcd4",
              "$leftMargin": 50,
              "$topMargin": 150,
              "$extraMargin": 50,
              "formula": "($(sensor.energy_consumption_tarif_1).statistics.sum + $(sensor.energy_consumption_tarif_2).statistics.sum).toFixed(1)",
              "state": ["⚡-", "f:state", "kWh"],
              "lines": [
                { "startX": 150, "startY": 200, "endX": 450, "endY": 200, "color": "#00bcd4" }
              ]
            },
            {
              "$labelText": "Solar",
              "$textSize": 14,
              "$borderColor": "orange",
              "$leftMargin": 250,
              "$topMargin": 30,
              "state": ["☀️⚡", "f:state", "kWh"],
              "formula": "($(sensor.modbus_ac_energy_kwh).statistics.sum).toFixed(1)",
              "lines": [
                {"startX": 150, "startY": 190, "endX": 290, "endY": 130, "controlX": 210, "controlY": 190, "color": "purple" },
                {"startX": 310, "startY": 130, "endX": 450, "endY": 190, "controlX": 380, "controlY": 190, "color": "orange" }
              ]
            },
            {
              "$textColor": "orange",
              "$leftMargin": 250,
              "$topMargin": 35,
              "$extraMargin": 10,
              "formula": "Math.floor($(sensor.solar_energy_intake_duration).state).toString() + 'h' + Math.floor(($(sensor.solar_energy_intake_duration).state % 1) * 60).toString().padStart(2, '0') + 'm'",
              "state": ["f:state", "f:attributes.unit_of_measurement"]
            },
            {
              "$labelText": "Battery",
              "$labelTopMargin": 105,
              "$borderColor": "#f062b5",
              "$textColor": "#f062b5",
              "$leftMargin": 250,
              "$topMargin": 275,
              "formula": "($(sensor.battery_load).statistics.sum).toFixed(1)",
              "state": ["↓ ", "f:state", "kWh"],
              "lines": [
                {"startX": 300, "startY": 130, "endX": 300, "endY": 275, "color": "#f062b5" },
                {"startX": 150, "startY": 210, "endX": 290, "endY": 275, "controlX": 210, "controlY": 210, "color": "purple" }
              ]
            },
            {
              "$textColor": "#00bcd4",
              "$leftMargin": 250,
              "$topMargin": 275,
              "$extraMargin": 60,
              "formula": "($(sensor.battery_unload).statistics.sum).toFixed(1)",
              "state": ["↑ ", "f:state", "kWh"],
              "lines": [
                {"startX": 310, "startY": 275, "endX": 450, "endY": 210, "controlX": 380, "controlY": 210, "color": "#00bcd4" }
              ]
            },
            {
              "$labelText": "Water",
              "$borderColor": "blue",
              "$leftMargin": 450,
              "$topMargin": 30,
              "state": ["f:state", "L"],
              "formula": "($(sensor.water_consumption.statistics.sum).toFixed(1)",
              "lines": [
                {"startX": 500, "startY": 130, "endX": 500, "endY": 150, "color": "blue" }
              ]
            },
            {
              "$textSize": 14,
              "$borderColor": "black",
              "$leftMargin": 450,
              "$topMargin": 150,
              "formula": "($(sensor.modbus_ac_energy_kwh).statistics.sum - $(sensor.energy_production_tarif_1).statistics.sum - $(sensor.energy_production_tarif_2).statistics.sum + $(sensor.energy_consumption_tarif_1).statistics.sum + $(sensor.energy_consumption_tarif_2).statistics.sum).toFixed(1)",
              "state": ["⌂", "f:state", "kWh"]
            },
            {
              "$labelText": "Gas",
              "$labelTopMargin": 105,
              "$borderColor": "#8e021b",
              "$leftMargin": 450,
              "$topMargin": 275,
              "formula": "($(sensor.gas_consumption).statistics.sum).toFixed(1)",
              "state": ["f:state", "m³"],
              "lines": [
                {"startX": 500, "startY": 250, "endX": 500, "endY": 275, "color": "#8e021b" }
              ]
            },
            {
              "$labelText": "Car",
              "$borderColor": "#5bd0cc",
              "$leftMargin": 650,
              "$topMargin": 30,
              "formula": "($(sensor.car_consumption).statistics.sum).toFixed(1)",
              "state": ["⚡ ", "f:state", "kWh"],
              "lines": [
                {"startX": 550, "startY": 190, "endX": 700, "endY": 130, "controlX": 625, "controlY": 190, "color": "#5bd0cc" }
              ]
            },
            {
              "$textColor": "black",
              "$leftMargin": 650,
              "$topMargin": 35,
              "$extraMargin": 10,
              "entity_id": "sensor.car_battery_percentage",
              "state": ["f:state", "f:attributes.unit_of_measurement"]
            }
          ]
        }
      },
      {
        "badges": {
          "items": [
            {
              "entity_id": "sensor.kmi_temp",
              // Return an array of fields that will be displayed on the intercom
              // Items prefixed with "f:" will fetch the json value
              "state": ["KMI", "\n", "f:state", "f:attributes.unit_of_measurement"]
            },
            {
              // This example fetches the data from another url, it must return a "state" field and "attributes" field with a nested "unit_of_measurement" field
              "url": "https://192.168.0.XX:8123/api/states/sensor.power_production",
              "state": ["⚡+", "\n", "f:state", "f:attributes.unit_of_measurement"]
            },
            {
              "entity_id": "sensor.modbus_ac_power",
              "state": ["☀️⚡", "\n", "f:state", "f:attributes.unit_of_measurement"],
              "when": "$state > 0"  // This will only include the entity if the field "state" > 0 
            },
            // Fetch the entity and return "state"
            "sensor.shellyem_a4e57cba5163_channel_1_power"
          ]
        },
        "buttons": {
          "items": [
            {
              // Will use the toggle service on HA to toggle an entity in a specific domain
              "domain": "light",
              "entity_id": "light.shelly_lamp_switch_0",
              "name": "TV"
            },
            {
              // This will toggle multiple entities seperated by a comma
              "domain": "light",
              "entity_id": "light.shelly_lamp_switch_0,light.mss425e_8575_outlet_1",
              "name": "☀️⚡ 💡 ! Living"
            },
            {
              "domain": "cover",
              "entity_id": "cover.living",
              "name": "Screen Living"
            }
          ]
        },
        "images": {
          "items": [
            {
              "width": 300,
              "height": 170,
              // You can use the scrypted webhook endpoint to get a snapshot of your security camera
              "source": "http://192.168.0.XX:11080/endpoint/@scrypted/webhook/public/XXX/fffffffffff/takePicture?parameters=[{\"picture\":{\"width\":300}}]"
            }
          ]
        },
        "switches":{
          "items": [
            {
              "domain": "light",
              "entity_id": "light.shelly_lamp_switch_0",
              "name": "TV",
              // Only include the item when state matches a simple condition
              "when": "$state != 'off'"
            }
          ]
        }
      }
    ]
  }  
}
```

#### 2. Patching HomePage.qml and MainApp.qml

> [!WARNING]
>
> The following procedure involves editing your existing GUI files.
> 
> I am not responsible if you break your system!
>

```
# Make the root system writeable and go into the skins directory
mount -oremount,rw /
cd /home/bticino/bin/gui/skins/default

# Make a backup of HomePage.qml
cp HomePage.qml HomePage.qml.bak
cp MainApp.qml MainApp.qml.bak

# Fetch the patch file
wget -O default.patch "https://raw.githubusercontent.com/slyoldfox/c300x-dashboard/main/default.patch"
# Apply the patch on HomePage.qml and MainApp.qml
patch -p1 < default.patch
```

#### 3. Adding HomeAssistant.qml and the javascript utility class

```
# Download HomeAssistant.qml and ha.js
wget -O HomeAssistant.qml "https://raw.githubusercontent.com/slyoldfox/c300x-dashboard/main/HomeAssistant.qml"
wget -O js/ha.js "https://raw.githubusercontent.com/slyoldfox/c300x-dashboard/main/ha.js"
```

#### 4. Reloading the GUI to test

To test your changes you can reboot the GUI of the intercom with:

```
cd /home/bticino
killall -9 BtClass_qws BtClass; ./bin/BtClass_qws &
```

If everything seems alright, you can reboot your intercom.

In case something is wrong, you can revert a patch with:

```
patch -R -p1 < default.patch
```
