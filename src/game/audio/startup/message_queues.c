#include "../../../../include/audio_runtime.h"

OSMesgQueue D_8018FF30;
OSMesg D_8018FF48[AUDIO_MESSAGE_COUNT];
OSMesgQueue D_8018FF68;
OSMesg D_8018FF80[AUDIO_MESSAGE_COUNT];

typedef char AudioMessageQueueStorageMustBe112Bytes[
    sizeof(D_8018FF30) + sizeof(D_8018FF48) +
    sizeof(D_8018FF68) + sizeof(D_8018FF80) == 112 ? 1 : -1];
