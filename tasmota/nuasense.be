# NuaSense for Tasmota (Berry, ESP32 builds): every 5 minutes, the readings of
# the sensors Tasmota already shows are sent to NuaSense.
#
# Put this file on the device (Tools → Manage File system), add
#   load("nuasense.be")
# to autoexec.be, set TOKEN below, restart.
# Not yet run on a device by NuaSense: report what you see.
import json
import string

var TOKEN = "xxxx-xxxx-xxxx"
var URL = "https://api.nuasense.com/station/" + TOKEN

# Tasmota sensor name → NuaSense field. Add yours; names: nuasense-reading.schema.json
var MAP = {
  "BME280#Temperature": "temperature",
  "BME280#Humidity": "humidity",
  "BME280#Pressure": "pressure",
  "SHT3X#Temperature": "temperature",
  "SHT3X#Humidity": "humidity",
  "DS18B20#Temperature": "soil_temperature",
  "SCD30#CarbonDioxide": "co2",
  "SCD40#CarbonDioxide": "co2",
}

def nuasense_send()
  var s = json.load(tasmota.read_sensors())
  if s == nil return end
  var body = {"device_id": tasmota.cmd("DeviceName")["DeviceName"], "software": "nuasense-tasmota/0.1.0"}
  for key: MAP.keys()
    var parts = string.split(key, "#")
    var sensor = s.find(parts[0])
    if sensor != nil && sensor.find(parts[1]) != nil
      body[MAP[key]] = sensor[parts[1]]
    end
  end
  var cl = webclient()
  cl.begin(URL)
  cl.add_header("Content-Type", "application/json")
  var code = cl.POST(json.dump(body))
  cl.close()
  print("NuaSense:", code)
end

tasmota.add_cron("0 */5 * * * *", nuasense_send, "nuasense")
