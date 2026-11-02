# Console uploads → NuaSense reading

What the NuaSense station receiver reads from each upload format, and the conversion applied. Fields not listed are ignored.

## Ecowitt (POST, form body) — also Froggit, Misol, Sainlogic, Fine Offset

| upload field | reading | conversion |
|---|---|---|
| `dateutc` | `time` | `YYYY-MM-DD HH:MM:SS` UTC |
| `tempf` | `temperature` | (°F − 32) × 5/9 |
| `humidity` | `humidity` | as is |
| `baromabsin` (fallback `baromrelin`) | `pressure` | inHg × 33.8639 |
| `windspeedmph` | `wind_speed` | mph × 0.44704 |
| `windgustmph` | `wind_gusts` | mph × 0.44704 |
| `winddir` | `wind_direction` | as is |
| `solarradiation` | `light` | W/m² × 120 |
| `yearlyrainin` (then `totalrainin`, `dailyrainin`) | `rain_mm` | the counter's increase since the previous accepted reading, inches × 25.4; a counter that resets is treated as a new start, not as negative rain |
| `PASSKEY` | identity | the station's path is bound to the first PASSKEY that uses it |

## Ambient Weather (GET, query string)

Same fields and conversions as Ecowitt; `PASSKEY` is the console's MAC address.

## Wunderground format (GET, `action=updateraw`)

| upload field | reading | conversion |
|---|---|---|
| `dateutc` | `time` | `YYYY-MM-DD HH:MM:SS` UTC, or `now` |
| `tempf` | `temperature` | (°F − 32) × 5/9 |
| `humidity` | `humidity` | as is |
| `baromin` | `pressure` | sea-level inHg → station pressure from the station's altitude |
| `windspeedmph`, `windgustmph`, `winddir` | wind | as above |
| `solarradiation` | `light` | W/m² × 120 |
| `rainin` / `dailyrainin` | `rain_mm` | counter increase, inches × 25.4 |
| `PASSWORD` (fallback `ID`) | identity | the station's token |

## Timing

The receiver keeps one reading per station per minute; consoles are asked to send every 60 s. Readings carrying a time more than 90 days old are refused.
