#include "../../../include/object_helpers.h"

/* A nonzero slot is free; the reset routine visits all 300 integers. */
int D_800C86C0[300];

typedef char ObjectSlotStorageMustBe1200Bytes[
    sizeof(D_800C86C0) == 1200 ? 1 : -1];
