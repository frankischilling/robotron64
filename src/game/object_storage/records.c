#include "../../../include/object.h"

/* The allocator accepts indices 0..299 and resets 120 bytes per record. */
ObjectRecord D_800BF918[300];

typedef char ObjectRecordStorageMustBe36000Bytes[
    sizeof(D_800BF918) == 36000 ? 1 : -1];
