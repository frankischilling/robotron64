#include "../../include/resource_bridge_internal.h"

int func_8003CB10(int kind, int current, unsigned char *path, int identifier)
{
    unsigned char unknownStack128[128];
    unsigned char unknownStack4[4];
    ResourceBridgeAnimationView *animation;
    int i;
    int result;
    int counter;

    if (D_80078268 != 0) {
        for (i = 0; i < 1000; i++) {
            D_800C95D0[i] = -1;
        }
        D_80078268 = 0;
    }
    if (D_800C95D0[identifier] != -1) {
        result = D_800C95D0[identifier];
    } else {
        counter = D_8007BB0C;
        result = counter;
        D_8007BB0C = result + 1;
        animation = (ResourceBridgeAnimationView *)(D_80078274 + result * 0x10);
        animation->identifier = identifier;
        animation->loaded = 0;
        D_800C95D0[identifier] = result;
    }
    D_8007BB14 = 1;
    func_8004BD00(-1, result, -1);
    D_8007BB14 = 0;
    return result;
}
