# ESP-IDF Port Plan

This document tracks the ESP-IDF port status, example layout, and validation plan for SRT on ESP32-class targets.

## Status

| Area                                                   | Status              |
| ------------------------------------------------------ | ------------------- |
| ESP-IDF component build                                | Passed              |
| ESP32-P4 startup test                                  | Passed              |
| `srt_startup()` / `srt_getversion()` / `srt_cleanup()` | Passed              |
| SRT socket connection                                  | Not fully validated |
| Data transmission                                      | Not fully validated |
| Encryption runtime test                                | Not validated       |

## Directory Layout

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

## Examples

These examples are intended for users. They should be simple, practical, and easy to run.

| Example           | Purpose                                        | PC-side tool                |
| ----------------- | ---------------------------------------------- | --------------------------- |
| `minimal_startup` | Verify SRT startup, version query, and cleanup | Not required                |
| `caller_text`     | ESP32 connects to a PC listener and sends text | `srt-live-transmit`         |
| `listener_text`   | ESP32 listens and receives text from PC        | `srt-live-transmit`         |
| `caller_binary`   | ESP32 sends binary data to PC                  | SRT tool or custom receiver |
| `listener_binary` | ESP32 receives binary data from PC             | SRT tool or custom sender   |
| `caller_live`     | ESP32 sends data in live mode                  | SRT tool or FFmpeg          |
| `listener_live`   | ESP32 receives data in live mode               | SRT tool or FFmpeg          |
| `caller_file`     | ESP32 sends data in file mode                  | `srt-file-transmit`         |
| `listener_file`   | ESP32 receives data in file mode               | `srt-file-transmit`         |
| `encrypted_text`  | Verify encrypted text transmission             | SRT tool with passphrase    |

## Validation Tests

These tests are intended for port validation. They should cover the main SRT APIs and runtime behavior on ESP-IDF.

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

## Suggested Order

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
