#include "../../../../include/audio_runtime.h"

AudioTaskRecord D_8014BE58[AUDIO_TASK_COUNT];

typedef char AudioTaskRecordStorageMustBe288Bytes[
    sizeof(D_8014BE58) == 288 ? 1 : -1];
