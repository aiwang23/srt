#include <stdio.h>

#include "srt.h"

extern "C" void app_main(void)
{
    printf("SRT minimal startup example\n");

    const int startupRet = srt_startup();
    printf("srt_startup() = %d\n", startupRet);

    const int version = srt_getversion();
    printf("srt_getversion() = 0x%08x\n", version);

    srt_cleanup();
    printf("srt_cleanup() done\n");
}