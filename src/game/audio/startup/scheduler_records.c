#include "../../../../include/audio_runtime.h"

SchedulerTask D_8014BF78[AUDIO_TASK_COUNT];

typedef char AudioSchedulerRecordStorageMustBe264Bytes[
    sizeof(D_8014BF78) == 264 ? 1 : -1];
