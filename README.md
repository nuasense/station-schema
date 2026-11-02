# NuaSense station schema

The shape of one weather-station reading as NuaSense stores it, and how the formats consumer consoles speak map onto it. Use it to validate what you send to the JSON endpoint, to build a decoder for a station NuaSense does not know yet, or to read NuaSense's exports.

- [`nuasense-reading.schema.json`](nuasense-reading.schema.json) — JSON Schema (2020-12) of a reading.
- [`mappings/ecowitt.md`](mappings/ecowitt.md) — how Ecowitt / Ambient / Wunderground upload fields become a reading.

## The reading

| field | unit | range |
|---|---|---|
| `time` | RFC 3339 | ≤ 90 days old |
| `temperature` | °C | −90 … 60 |
| `humidity` | % | 0 … 100 |
| `pressure` | hPa, station level | 300 … 1100 |
| `light` | lux | 0 … 200 000 |
| `wind_speed` | m/s | 0 … 120 |
| `wind_gusts` | m/s | 0 … 150 |
| `wind_direction` | ° from north | 0 … 360 |
| `rain_mm` | mm since the previous reading | 0 … 300 |

Anything outside a range is refused with the offending row named: a sensor wired wrong or a unit mix-up is cheapest to catch here, before it becomes an agronomic recommendation.

## Ways in

| door | who | format |
|---|---|---|
| `http://ingest.nuasense.com/station/<token>` | consoles and bridges (Ecowitt, Ambient, Wunderground mode; weewx, Meteobridge, Node-RED) | the console's own format; converted to the reading above |
| `POST https://api.nuasense.com/api/nuasense/v1/ingest/readings` | integrators with an API key | `{"station_id": "...", "readings": [ reading, … ]}`, ≤ 500 rows, all-or-nothing |
| `POST https://api.nuasense.com/lorawan/<token>` | LoRaWAN networks: The Things Stack webhook, ChirpStack HTTP integration (`?event=up`) | the network's uplink JSON; decoded fields are read by name (`temperature`, `humidity`, `pressure`, `wind_speed`, `wind_gusts`, `wind_direction`, `light`/`irradiation`, `rainfall_total` or `rain`; SenseCAP `messages[]`), converted to the reading above |

Packages: [node-red-contrib-nuasense](https://github.com/nuasense/node-red-contrib-nuasense) · [weewx-nuasense](https://github.com/nuasense/weewx-nuasense) · [homeassistant-nuasense](https://github.com/nuasense/homeassistant-nuasense).

## Your data

When you connect a station, NuaSense stores its readings and computes your forecast, spray windows and risks from them. The readings are used aggregated and anonymised to improve forecasts and models for everyone; they are never passed on individually without your opt-in. You can disconnect the station in the console at any time and have all its data deleted.

MIT licence.
