#include "../../include/rom_files.h"
#include "../../include/game_memory.h"
#include "../../include/debug_output.h"
#include "../../include/pi.h"

extern unsigned char D_80095B50[];
extern unsigned char D_80095B84[];
extern unsigned char D_80095B90[];
extern unsigned char D_80095B98[];
extern unsigned char D_80095BA0[];
extern unsigned char D_80095BA8[];

void func_80021B38(void *resource);

int func_8004ED78(unsigned char *name)
{
    int i;

    for (i = 0; i < D_80141204; i++) {
        if (func_8003B768(name, (i << 5) + (unsigned char *)D_80141200 + 1) == 0) {
            return i;
        }
    }
    func_800496E0(D_80095B50, name, i, D_80095B84, 0xCB);
    return 0;
}

void func_8004EE30(void *destination, unsigned int deviceAddress, int count)
{
    int i;

    count = (count + 3) >> 2;
    for (i = 0; i < count; i++) {
        func_80063560(deviceAddress, destination);
        deviceAddress += 4;
        destination = (unsigned int *)destination + 1;
    }
}

int func_8004EE9C(unsigned char *name, void *destination)
{
    int size;
    RomFileEntry *entry;

    func_8004EBE4();
    size = func_8004ED78(name);
    entry = (RomFileEntry *)((unsigned char *)D_80141200 + (size << 5));
    size = entry->size;
    func_8004EE30(destination, entry->deviceAddress, size);
    if ((func_8003B838(name, D_80095B90, 5) == 0) ||
        (func_8003B838(name, D_80095B98, 5) == 0) ||
        (func_8003B838(name, D_80095BA0, 5) == 0)) {
        if (func_8003B7FC(func_8003B4C0(name, '.'), D_80095BA8) == 0) {
            func_80021B38(destination);
        }
    }
    return size;
}

int func_8004EF6C(unsigned char *name)
{
    func_8004EBE4();
    return D_80141200[func_8004ED78(name)].size;
}
