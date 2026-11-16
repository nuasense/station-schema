# NuaSense station schema

The shape of one reading as NuaSense stores it: a weather station, and everything else along an agricultural chain (soil, water, greenhouse, livestock housing, beehives, storage and cold chain, transport, air, energy). How the formats consumer consoles speak map onto it. And ready-made code for sensors you build yourself.

- [`nuasense-reading.schema.json`](nuasense-reading.schema.json): JSON Schema (2020-12) of a reading, generated from the receiver's own vocabulary.
- [`mappings/ecowitt.md`](mappings/ecowitt.md): how Ecowitt / Ambient / Wunderground upload fields become a reading.
- Your own sensor: [Arduino / PlatformIO](https://github.com/nuasense/nuasense-arduino) · [ESPHome](esphome/nuasense-weather-soil.yaml) · [Python (Raspberry Pi, any computer): `pip install nuasense`](https://pypi.org/project/nuasense/) · [MicroPython (ESP32, Pico W)](micropython/nuasense.py) · [Tasmota](tasmota/nuasense.be) · [rtl_433](guides/rtl433.md) · [Datacake, TagoIO, Ubidots](guides/datacake-tagoio-ubidots.md)

## Your own sensor in one POST

Get a token in the console (**External stations → Add a station → I built it myself**; the first three stations are free), then:

```
POST https://api.nuasense.com/station/<token>
Content-Type: application/json

{"device_id": "esp32-garden", "temperature": 21.4, "humidity": 63, "soil_moisture": 34, "soil_moisture_2": 41.5}
```

- One key per value, with the names and units below. A name that is not on the list is not stored.
- `device_id` is any name for your device. It binds the token to it, so a second device cannot use the same address.
- The time is the moment we receive the POST. Send every few minutes: uploads less than a minute apart are acknowledged and dropped.
- Answers: `200` stored, `400` nothing readable or more than 40 values in one upload, `404` unknown token, `409` the token belongs to another device, `429` too many uploads.
- Plain `http://ingest.nuasense.com/station/<token>` works too, as weather consoles use it.

## The reading

| group | fields (unit) |
|---|---|
| weather | `temperature` (°C) · `humidity` (%) · `pressure` (hPa, station level) · `light` (lux) · `wind_speed`, `wind_gusts` (m/s) · `wind_direction` (°) · `rain_mm` (mm since the previous reading) · `uv_index` · `leaf_wetness` (%) |
| soil | `soil_moisture` (% vol) · `soil_temperature` (°C) · `soil_ec` (mS/cm) · `soil_tension` (kPa) · `soil_ph` · `probe_temperature` (°C, soil or water probe) |
| water | `water_level` (m) · `water_temperature` (°C) · `water_ec` (mS/cm) · `water_ph` · `dissolved_oxygen` (mg/L) · `turbidity` (NTU) · `flow_rate` (L/min) · `water_pressure` (bar) |
| greenhouse, plant | `greenhouse_temperature` (°C) · `greenhouse_humidity` (%) · `co2` (ppm) · `par` (µmol/m²/s) · `leaf_temperature` (°C) · `stem_diameter` (µm) |
| livestock housing | `ammonia` (ppm) |
| beehive | `hive_weight` (kg) · `hive_temperature` (°C) · `hive_humidity` (%) |
| storage, cold chain | `storage_temperature` (°C) · `storage_humidity` (%) · `ethylene` (ppm) · `grain_moisture` (%) · `grain_temperature` (°C) · `door_open` (0/1) |
| transport | `gps_latitude`, `gps_longitude` (°) · `gps_speed` (km/h) |
| air | `pm1`, `pm25`, `pm10` (µg/m³) · `voc_index` |
| energy | `battery_voltage` (V) · `battery_percent` (%) · `power`, `pv_power` (W) |

Several sensors of one kind (everything outside the weather group, and leaf wetness): `soil_moisture_2` … `soil_moisture_8`; without a number it is channel 1. Ranges are in the schema. A value outside its range is refused: a sensor wired wrong or a unit mix-up is cheapest to catch here, before it becomes a recommendation.

Measured values only. Cheap "NPK" soil probes estimate nutrients from conductivity and moisture; nutrient fields are therefore not accepted. A pH electrode is a measurement, and is.

## Ways in

| door | who | format |
|---|---|---|
| `https://api.nuasense.com/station/<token>` | your own sensor (ESP32, Arduino, Raspberry Pi, ESPHome, Tasmota) | the JSON above |
| `http://ingest.nuasense.com/station/<token>` | consoles and bridges (Ecowitt, Ambient, Wunderground mode; weewx, Meteobridge, Node-RED; Sensor.Community "custom API") | the console's own format; converted to the reading. Ecowitt add-ons are taken too: soil moisture, temperature probes, leaf wetness, particles, CO2, UV |
| `POST https://api.nuasense.com/api/nuasense/v1/ingest/readings` | integrators with an API key | `{"station_id": "...", "readings": [ reading, … ]}`, ≤ 500 rows, all-or-nothing |
| `POST https://api.nuasense.com/lorawan/<token>` | LoRaWAN networks: The Things Stack webhook, ChirpStack HTTP integration (`?event=up`) | the network's uplink JSON; decoded fields are read by name (weather; soil moisture and temperature, CO2, particles, PAR, battery; SenseCAP `messages[]`), converted to the reading |

Packages: [node-red-contrib-nuasense](https://github.com/nuasense/node-red-contrib-nuasense) · [weewx-nuasense](https://github.com/nuasense/weewx-nuasense) · [homeassistant-nuasense](https://github.com/nuasense/homeassistant-nuasense) · [nuasense-arduino](https://github.com/nuasense/nuasense-arduino).

## Your data

When you connect a station, NuaSense stores its readings and computes your forecast, spray windows and risks from them. The readings are used aggregated and anonymised to improve forecasts and models for everyone; they are never passed on individually without your opt-in. You can disconnect the station in the console at any time and have all its data deleted.

MIT licence.
