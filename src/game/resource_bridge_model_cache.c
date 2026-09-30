#include "../../include/resource_bridge_internal.h"

int func_8003C94C(int kind, int current, unsigned char *path, int identifier)
{
    unsigned char filename[128];
    unsigned char extension[4];
    ResourceBridgeModelCacheEntry *entries;
    int index;
    int result;

    if (D_80078264 != 0) {
        for (index = 0; index < 1000; index++) {
            D_800C8E00[index] = -1;
        }
        D_80078264 = 0;
    }
    if (D_800C8E00[identifier] != -1) {
        result = D_800C8E00[identifier];
    } else {
        result = kind;
        D_800C8E00[identifier] = kind;
        entries = (ResourceBridgeModelCacheEntry *)(D_80078274 + 0x14);
        entries[result].identifier = identifier;
        entries[result].loaded = 0;
    }
    D_8007BB14 = 1;
    func_8004BD00(result, -1, -1);
    D_8007BB14 = 0;
    return result;
}
