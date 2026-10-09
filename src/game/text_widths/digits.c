#include "../../../include/text.h"

int D_80072BA8[10] = {5, 3, 5, 5, 5, 5, 5, 5, 5, 5};

typedef char DigitWidthsMustBe40Bytes[sizeof(D_80072BA8) == 40 ? 1 : -1];
