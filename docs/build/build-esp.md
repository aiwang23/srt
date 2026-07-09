# ESP-IDF Build and Port Plan

This document describes the experimental ESP-IDF component build for SRT and tracks the planned validation work for ESP32-class targets.

## Status

| Area                                                   | Status               |
| ------------------------------------------------------ | -------------------- |
| ESP-IDF component build                                | Passed               |
| ESP32-P4 startup test                                  | Passed               |
| `srt_startup()` / `srt_getversion()` / `srt_cleanup()` | Passed               |
| SRT socket connection                                  | Not fully validated  |
| Data transmission                                      | Not fully validated  |
| Encryption build with ESP-IDF mbedTLS                  | Compile probe passed |
| Encryption runtime test                                | Not validated        |

## Tested Environment

| Item          | Value                              |
| ------------- | ---------------------------------- |
| ESP-IDF       | v5.5.4                             |
| Target        | ESP32-P4                           |
| SRT           | 1.5.5                              |
| Build mode    | ESP-IDF component                  |
| Basic example | `examples/esp-idf/minimal_startup` |

## Build Requirements

Enable C++ exceptions in ESP-IDF:

```text
CONFIG_COMPILER_CXX_EXCEPTIONS=y
CONFIG_COMPILER_CXX_EXCEPTIONS_EMG_POOL_SIZE=0
```

For ESP32-P4 early revisions, set the chip revision correctly. Example for ESP32-P4 v1.x:

```text
CONFIG_ESP32P4_SELECTS_REV_LESS_V3=y
CONFIG_ESP32P4_REV_MIN_100=y
CONFIG_ESP32P4_REV_MIN_FULL=100
CONFIG_ESP32P4_REV_MAX_FULL=199
```

## Build Minimal Startup Example

```bash
cd examples/esp-idf/minimal_startup
idf.py set-target esp32p4
idf.py build
```

## Flash and Monitor

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

## Use as an ESP-IDF Component

The SRT repository can be used directly as an ESP-IDF component.

Example project layout:

```text
my_project/
├── main/
└── components/
    └── srt/
        ├── CMakeLists.txt
        ├── srtcore/
        ├── haicrypt/
        ├── cmake/
        └── port/esp-idf/
```

The ESP-IDF build path is selected by `ESP_PLATFORM` in the top-level `CMakeLists.txt`. Normal Linux, Windows, and macOS CMake builds should continue to use the original SRT build system.

## Current Limitations

| Area                           | Status                 |
| ------------------------------ | ---------------------- |
| Basic lifecycle                | Passed                 |
| UDP socket path                | Partially investigated |
| SRT caller/listener connection | Not fully validated    |
| Text send/receive              | Not validated          |
| Binary send/receive            | Not validated          |
| SRT stats                      | Not validated          |
| Nonblocking mode               | Not validated          |
| SRT epoll                      | Not validated          |
| Runtime encryption             | Not validated          |
| Long-running stability         | Not validated          |

## Example Layout Plan

Examples are intended for users. They should be simple, practical, and easy to run.

```text
examples/esp-idf/
├── minimal_startup
├── caller_text
├── listener_text
├── caller_binary
├── listener_binary
├── caller_live
├── listener_live
├── caller_file
├── listener_file
└── encrypted_text
```

| Example           | Purpose                                        | PC-side tool                |
| ----------------- | ---------------------------------------------- | --------------------------- |
| `minimal_startup` | Verify startup, version query, and cleanup     | Not required                |
| `caller_text`     | ESP32 connects to a PC listener and sends text | `srt-live-transmit`         |
| `listener_text`   | ESP32 listens and receives text from PC        | `srt-live-transmit`         |
| `caller_binary`   | ESP32 sends binary data to PC                  | SRT tool or custom receiver |
| `listener_binary` | ESP32 receives binary data from PC             | SRT tool or custom sender   |
| `caller_live`     | ESP32 sends data in live mode                  | SRT tool or FFmpeg          |
| `listener_live`   | ESP32 receives data in live mode               | SRT tool or FFmpeg          |
| `caller_file`     | ESP32 sends data in file mode                  | `srt-file-transmit`         |
| `listener_file`   | ESP32 receives data in file mode               | `srt-file-transmit`         |
| `encrypted_text`  | Verify encrypted text transmission             | SRT tool with passphrase    |

## Validation Test Plan

Tests are intended for port validation. They should cover the main SRT APIs and runtime behavior on ESP-IDF.

```text
tests/esp-idf/
├── platform/
├── lifecycle/
├── connection/
├── send_recv/
├── modes/
├── options/
├── nonblocking/
├── epoll/
├── stats/
├── encryption/
├── stability/
└── media_mock/
```

| Category    | Test                             | Purpose                                        |
| ----------- | -------------------------------- | ---------------------------------------------- |
| Platform    | `platform/udp_socket_probe`      | Verify UDP socket, bind, and close             |
| Platform    | `platform/sendmsg_recvmsg_probe` | Verify lwIP `sendmsg()` and `recvmsg()`        |
| Lifecycle   | `lifecycle/startup_cleanup`      | Verify `srt_startup()` and `srt_cleanup()`     |
| Lifecycle   | `lifecycle/socket_create_close`  | Verify `srt_create_socket()` and `srt_close()` |
| Lifecycle   | `lifecycle/socket_recreate`      | Verify repeated socket create/close            |
| Connection  | `connection/bind_probe`          | Verify `srt_bind()`                            |
| Connection  | `connection/connect_probe`       | Verify ESP32 caller to PC listener             |
| Connection  | `connection/listen_accept_probe` | Verify ESP32 listener accepting PC caller      |
| Send/Recv   | `send_recv/caller_text_once`     | ESP32 sends one text message                   |
| Send/Recv   | `send_recv/listener_text_once`   | ESP32 receives one text message                |
| Send/Recv   | `send_recv/caller_binary_once`   | ESP32 sends binary data                        |
| Send/Recv   | `send_recv/listener_binary_once` | ESP32 receives binary data                     |
| Send/Recv   | `send_recv/payload_size_sweep`   | Test multiple payload sizes                    |
| Modes       | `modes/live_caller`              | Verify caller live mode                        |
| Modes       | `modes/live_listener`            | Verify listener live mode                      |
| Modes       | `modes/file_caller`              | Verify caller file mode                        |
| Modes       | `modes/file_listener`            | Verify listener file mode                      |
| Options     | `options/latency`                | Verify latency-related options                 |
| Options     | `options/mss`                    | Verify MSS option                              |
| Options     | `options/payload_size`           | Verify payload size option                     |
| Options     | `options/blocking`               | Verify blocking and nonblocking settings       |
| Nonblocking | `nonblocking/connect`            | Verify nonblocking connection                  |
| Nonblocking | `nonblocking/send_recv`          | Verify nonblocking send/recv                   |
| Epoll       | `epoll/basic`                    | Verify SRT epoll create/add/wait/release       |
| Stats       | `stats/after_connect`            | Read stats after connection                    |
| Stats       | `stats/during_send`              | Read stats during sending                      |
| Stats       | `stats/during_recv`              | Read stats during receiving                    |
| Encryption  | `encryption/passphrase_caller`   | Verify encrypted caller mode                   |
| Encryption  | `encryption/passphrase_listener` | Verify encrypted listener mode                 |
| Encryption  | `encryption/wrong_passphrase`    | Verify failed connection with wrong passphrase |
| Stability   | `stability/long_run_send`        | Long-running send test                         |
| Stability   | `stability/long_run_recv`        | Long-running receive test                      |
| Stability   | `stability/reconnect_caller`     | Verify caller reconnect behavior               |
| Stability   | `stability/reconnect_listener`   | Verify repeated listener connections           |
| Media Mock  | `media_mock/mjpeg_sender`        | Send simulated MJPEG frames                    |
| Media Mock  | `media_mock/mjpeg_receiver`      | Receive simulated MJPEG frames                 |
| Media Mock  | `media_mock/h264_sender`         | Send simulated H.264 Annex-B data              |
| Media Mock  | `media_mock/h264_receiver`       | Receive simulated H.264 Annex-B data           |

## Suggested Validation Order

| Stage | Scope                            |
| ----- | -------------------------------- |
| 1     | `minimal_startup`                |
| 2     | `platform/*`                     |
| 3     | `lifecycle/*`                    |
| 4     | `connection/*`                   |
| 5     | `send_recv/*`                    |
| 6     | `modes/*` and `options/*`        |
| 7     | `stats/*` and `nonblocking/*`    |
| 8     | `epoll/*`                        |
| 9     | `encryption/*`                   |
| 10    | `stability/*` and `media_mock/*` |

## Success Criteria

| Completed scope                        | Meaning                                                |
| -------------------------------------- | ------------------------------------------------------ |
| `minimal_startup`                      | The ESP-IDF component can build, link, and start       |
| Platform + lifecycle tests             | ESP-IDF socket and SRT basic lifecycle are usable      |
| Connection + send/recv tests           | Core SRT communication works                           |
| Modes + options + stats tests          | Common SRT features are covered                        |
| Nonblocking + epoll + encryption tests | Advanced SRT features are covered                      |
| Stability + media mock tests           | The port is ready for real media-streaming experiments |
