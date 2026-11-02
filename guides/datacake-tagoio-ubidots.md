# Datacake, TagoIO, Ubidots → NuaSense

If your LoRaWAN stations already land on one of these platforms, there are two ways to also get them into NuaSense. The first needs nothing from the platform at all.

## A. Add NuaSense as a second webhook in your network server (recommended)

Datacake, TagoIO and Ubidots receive your uplinks from The Things Stack or ChirpStack. Both network servers deliver the same uplink to as many endpoints as you like, so the simplest route is one more webhook next to the one that feeds the platform:

- **The Things Stack:** Application → Integrations → Webhooks → *Add webhook* → NuaSense (once the template is merged; until then *Custom webhook*, base URL `https://api.nuasense.com/lorawan/<token>`, format JSON, enable *Uplink message*).
- **ChirpStack:** Application → Integrations → HTTP → event endpoint URL `https://api.nuasense.com/lorawan/<token>`, encoding JSON.

`<token>` is the part after `/station/` in the path the NuaSense console shows for the station (External stations → Add a station → *Home Assistant / weewx / Meteobridge / Node-RED*). NuaSense reads the decoded payload by field name (temperature, humidity, pressure, wind, light or irradiation, rain) and the station gets the agronomy computed on it. Nothing changes for the platform.

## B. Forward from the platform itself

All three can call an external URL when a device reports. Point the call at `https://api.nuasense.com/lorawan/<token>` with a JSON body in ChirpStack's shape; NuaSense needs only three things in it:

```json
{
  "deviceInfo": { "devEui": "<the device's EUI>", "deviceName": "<any name>" },
  "time": "<ISO 8601 time of the reading>",
  "object": {
    "temperature": 17.4,
    "humidity": 90,
    "pressure": 759.9,
    "wind_speed": 2.0,
    "wind_gusts": 4.5,
    "wind_direction": 110,
    "rainfall_total": 254.0,
    "irradiation": 226
  }
}
```

Field names in `object` are flexible (see the schema README); units are °C, %, hPa, m/s, degrees, mm as a running total, W/m² or `light` in lux. The DevEUI is what binds the token to the device, so keep it constant.

Where the call is configured:

- **Datacake:** Rules → new rule on the device → action *Webhook*, method POST, body from the template above with the rule's device variables; add the header `Content-Type: application/json`. The exact placeholder syntax for device fields is shown in Datacake's rule editor (variable list) — use it for the values in `object`.
- **TagoIO:** Actions → *Run analysis* or *Post data to endpoint* on variable change, with the body above built from the device's variables.
- **Ubidots:** Events → new event on the device → action *Webhook*, POST, custom JSON body with `{{variables}}` for the values.

Route A is simpler and keeps one copy of the raw uplink per network server; route B is for devices that do not come through a LoRaWAN network server (cellular, Wi-Fi, Modbus) and are only in the platform.

## Your data

When you connect a station, NuaSense stores its readings and computes your forecast, spray windows and risks from them. The readings are used aggregated and anonymised to improve forecasts and models for everyone; they are never passed on individually without your opt-in. You can disconnect the station in the console at any time and have all its data deleted.
