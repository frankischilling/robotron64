#include "../../../include/text.h"

int D_80072B40[26] = {
    5, 5, 5, 5, 5, 5, 5, 5, 3, 5, 5, 5, 6,
    5, 5, 5, 5, 5, 5, 5, 5, 5, 6, 5, 5, 5
};

typedef char LowercaseWidthsMustBe104Bytes[sizeof(D_80072B40) == 104 ? 1 : -1];
