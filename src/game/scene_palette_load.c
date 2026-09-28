#include "../../include/platform_services.h"
#include "../../include/palette_effects.h"

void func_800314FC(unsigned char *path)
{
    int index;

    func_8003BFE4(func_8003BFDC(path));
    func_80031C10();
    for (index = 0; index < 256; index++) {
        func_8003C14C(&D_8009CD18[index], index);
    }
}
