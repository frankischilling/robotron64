#include "../../include/script_service_internal.h"
#include "../../include/scene_commands_internal.h"
#include "../../include/resource_strings.h"
#include "../../include/tweak_internal.h"

extern int D_8009EE04;
extern int D_800BA7A0;
extern int D_800BAB18[];

void func_8001CB50(int *command)
{
    unsigned char *filename;

    filename = func_800383C4(command[1]);
    D_800781C0 = 0;
    func_80037A20();
    D_800781C0 = 1;
    D_8009EE04 = -1;
    func_8003264C(filename, D_80078060, 1);
}

void func_8001CBB0(int *command)
{
    func_8003264C(func_800383C4(command[1]), D_80078040, 1);
}

void func_8001CBE8(int *command)
{
    if (D_800A4530 == 80) {
        func_8001C0D0((char *)D_80090690);
    }
    D_800A42B0[D_800A4530].startLevel = D_800BA7A0;
    D_800A42B0[D_800A4530].name = command[1];
    D_800A4530++;
}

void func_8001CC5C(int *command)
{
    int name;

    name = command[1];
    if (D_800BA7A0 >= 220) {
        func_8001C0D0((char *)D_800906A0);
    }
    D_800BAB18[D_800BA7A0] = name;
    D_800BA7A0++;
}

void func_8001CCC0(int *command)
{
    func_8003264C(func_800383C4(command[1]), D_80077E80, 1);
}

void func_8001CCF8(int value)
{
}

void func_8001CD00(int value)
{
    D_8009EFB4 = 1;
}

void func_8001CD14(void)
{
}

void func_8001CD1C(unsigned char *filename)
{
    func_80038498(D_800906BC);
    func_8001CD14();
    func_8003264C(filename, D_80077EB8, 1);
}

void func_8001CD60(void)
{
    D_800BA7A0 = 0;
    D_800A4530 = 0;
    func_800374D0();
    func_80038390();
}
