# ESP-IDF Minimal Startup

This example verifies that SRT can be built as an ESP-IDF component and that the basic SRT lifecycle works on the target.

## Tested

- ESP-IDF v5.5.4
- ESP32-P4
- SRT 1.5.5

## Build

```bash
idf.py set-target esp32p4
idf.py build
```

## Flash and monitor

```bash
idf.py flash monitor
```

Expected output:

```text
SRT minimal startup example
srt_startup() = 0
srt_getversion() = 0x00010505
srt_cleanup() done
```

## Notes

This example only verifies:

* SRT component build
* link
* `srt_startup()`
* `srt_getversion()`
* `srt_cleanup()`

It does not test SRT socket connection or data transmission.

