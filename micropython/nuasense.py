# NuaSense for MicroPython (ESP32, Raspberry Pi Pico W) and CPython.
#
#   import nuasense
#   nuasense.send("xxxx-xxxx-xxxx", "pico-greenhouse", {"temperature": 24.1, "co2": 612})
#
# Names and units: nuasense-reading.schema.json. Returns the HTTP status
# (200 = stored, 404 unknown token, 409 token of another device).
try:
    import urequests as requests  # MicroPython
except ImportError:
    import requests  # CPython (Raspberry Pi)

VERSION = "0.1.0"


def send(token, device_id, values, https=True):
    token = "".join(c for c in token.lower() if c.isalpha() or c.isdigit())
    body = {"device_id": device_id, "software": "nuasense-micropython/" + VERSION}
    for name, value in values.items():
        if value is None or value != value:  # None or NaN
            continue
        body[name] = value
    host = "https://api.nuasense.com" if https else "http://ingest.nuasense.com"
    r = requests.post(host + "/station/" + token, json=body, headers={"Content-Type": "application/json"})
    status = r.status_code
    r.close()
    return status
