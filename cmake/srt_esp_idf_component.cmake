set(SRT_ROOT_DIR "${CMAKE_CURRENT_LIST_DIR}/..")
set(SRTCORE_DIR "${SRT_ROOT_DIR}/srtcore")
set(HAICRYPT_DIR "${SRT_ROOT_DIR}/haicrypt")
set(SRT_ESP_IDF_PORT_DIR "${SRT_ROOT_DIR}/port/esp-idf")

string(REPLACE "." ";" SRT_VERSION_PARTS "${SRT_VERSION}")
list(GET SRT_VERSION_PARTS 0 SRT_VERSION_MAJOR)
list(GET SRT_VERSION_PARTS 1 SRT_VERSION_MINOR)
list(GET SRT_VERSION_PARTS 2 SRT_VERSION_PATCH)

# if(NOT CONFIG_COMPILER_CXX_EXCEPTIONS)
#     message(FATAL_ERROR
#         "SRT ESP-IDF port requires CONFIG_COMPILER_CXX_EXCEPTIONS=y. "
#         "Run idf.py menuconfig -> Component config -> Compiler options -> Enable C++ exceptions.")
# endif()

configure_file(
    "${SRTCORE_DIR}/version.h.in"
    "${CMAKE_CURRENT_BINARY_DIR}/version.h"
    @ONLY
)

set(SRT_SRCS
    "${SRT_ESP_IDF_PORT_DIR}/nanosleep.c"

    "${HAICRYPT_DIR}/cryspr.c"
    "${HAICRYPT_DIR}/cryspr-mbedtls.c"
    "${HAICRYPT_DIR}/hcrypt.c"
    "${HAICRYPT_DIR}/hcrypt_ctx_rx.c"
    "${HAICRYPT_DIR}/hcrypt_ctx_tx.c"
    "${HAICRYPT_DIR}/hcrypt_rx.c"
    "${HAICRYPT_DIR}/hcrypt_sa.c"
    "${HAICRYPT_DIR}/hcrypt_tx.c"
    "${HAICRYPT_DIR}/hcrypt_xpt_srt.c"
    "${HAICRYPT_DIR}/haicrypt_log.cpp"

    "${SRTCORE_DIR}/api.cpp"
    "${SRTCORE_DIR}/buffer_snd.cpp"
    "${SRTCORE_DIR}/buffer_rcv.cpp"
    "${SRTCORE_DIR}/buffer_tools.cpp"
    "${SRTCORE_DIR}/cache.cpp"
    "${SRTCORE_DIR}/channel.cpp"
    "${SRTCORE_DIR}/common.cpp"
    "${SRTCORE_DIR}/core.cpp"
    "${SRTCORE_DIR}/crypto.cpp"
    "${SRTCORE_DIR}/epoll.cpp"
    "${SRTCORE_DIR}/fec.cpp"
    "${SRTCORE_DIR}/handshake.cpp"
    "${SRTCORE_DIR}/list.cpp"
    "${SRTCORE_DIR}/logger_default.cpp"
    "${SRTCORE_DIR}/logger_defs.cpp"
    "${SRTCORE_DIR}/logging.cpp"
    "${SRTCORE_DIR}/md5.cpp"
    "${SRTCORE_DIR}/packet.cpp"
    "${SRTCORE_DIR}/packetfilter.cpp"
    "${SRTCORE_DIR}/queue.cpp"
    "${SRTCORE_DIR}/congctl.cpp"
    "${SRTCORE_DIR}/socketconfig.cpp"
    "${SRTCORE_DIR}/srt_c_api.cpp"
    "${SRTCORE_DIR}/srt_compat.c"
    "${SRTCORE_DIR}/strerror_defs.cpp"
    "${SRTCORE_DIR}/sync.cpp"
    "${SRTCORE_DIR}/sync_cxx11.cpp"
    "${SRTCORE_DIR}/tsbpd_time.cpp"
    "${SRTCORE_DIR}/window.cpp"
)

idf_component_register(
    SRCS ${SRT_SRCS}
    INCLUDE_DIRS
    "${SRT_ESP_IDF_PORT_DIR}"
    "${SRTCORE_DIR}"
    "${HAICRYPT_DIR}"
    "${CMAKE_CURRENT_BINARY_DIR}"
    REQUIRES lwip pthread esp_rom freertos mbedtls
)

target_compile_definitions(${COMPONENT_LIB} PRIVATE
    NDEBUG=1
    SRT_VERSION="${SRT_VERSION}"

    POSIX=1
    UNIX=1

    ENABLE_CXX11=1
    ENABLE_STDCXX_SYNC=1
    ENABLE_MONOTONIC_CLOCK=1

    SRT_ENABLE_APP_READER=1
    SRT_ENABLE_CLOSE_SYNCH=1
    HAVE_INET_PTON=1

    SRT_ENABLE_ENCRYPTION=1
    USE_MBEDTLS=1
)

target_compile_options(${COMPONENT_LIB} PRIVATE
    -std=gnu++17
    -Wno-error
    -Wno-unused-parameter
    -Wno-missing-field-initializers
    -Wno-unused-variable
    -Wno-unused-function
)
