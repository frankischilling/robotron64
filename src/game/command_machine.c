#include "../../include/command_script.h"
#include "../../include/text.h"

extern int D_8009EFB8;
extern char D_80094154[];

void func_800327AC(int *command)
{
    int machine;

    D_8009EFB8 = 0;
    machine = command[1];
    switch (machine) {
    case 0:
    case 1:
    case 3:
    case 5:
        break;
    case 2:
        D_8009EFB8 = 1;
        break;
    case 4:
        D_8009EFB8 = 1;
        break;
    case 7:
        D_8009EFB8 = 1;
        break;
    default:
        func_8001C0D0(D_80094154);
        break;
    }
}
