#ifndef ROBOTRON_OBJECT_HISTORY_INTERNAL_H
#define ROBOTRON_OBJECT_HISTORY_INTERNAL_H

#include "early_game_state.h"

typedef struct ObjectHistoryRecord {
    int x;
    int y;
    int z;
    int angle;
} ObjectHistoryRecord;

typedef char ObjectHistoryRecordMustBe16Bytes[
    sizeof(ObjectHistoryRecord) == 16 ? 1 : -1];

/* Each slot contains sixteen records. The table's full extent is unresolved. */
extern ObjectHistoryRecord D_8013FE00[];

void func_8004E820(EarlyGameActor *actor);

#endif
