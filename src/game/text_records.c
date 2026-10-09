#include "../../include/text.h"

TextRecord D_800B6FF8[30];

typedef char TextRecordMustBe268Bytes[sizeof(TextRecord) == 0x10C ? 1 : -1];
typedef char TextRecordPoolMustBe8040Bytes[
    sizeof(D_800B6FF8) == 0x1F68 ? 1 : -1];
