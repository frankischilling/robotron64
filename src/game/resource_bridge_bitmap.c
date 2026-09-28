#include "../../include/resource_bridge_internal.h"

int func_8003CA34(int current, unsigned char *path, int identifier)
{
    unsigned char unknownStack4[4];
    ResourceBridgeBitmapView *bitmap;
    int i;
    int result;
    int counter;

    if (D_8007826C != 0) {
        for (i = 0; i < 1000; i++) {
            D_800C9DA0[i] = -1;
        }
        D_8007826C = 0;
    }
    if (D_800C9DA0[identifier] != -1) {
        result = D_800C9DA0[identifier];
    } else {
        counter = D_8007BB10;
        result = counter;
        bitmap = (ResourceBridgeBitmapView *)(D_80078274 + result * 8);
        bitmap->identifier = identifier;
        bitmap->loaded = 0;
        D_8007BB10 = result + 1;
        D_800C9DA0[identifier] = result;
    }
    D_8007BB14 = 1;
    func_8004BD00(-1, -1, result);
    D_8007BB14 = 0;
    return result;
}
