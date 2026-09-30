#include "../../include/save_menu_legacy_internal.h"
#include "../../include/controller_services.h"

typedef struct PakMenuFileName {
    unsigned char name[30];
} PakMenuFileName;

typedef char PakMenuFileNameMustBe30Bytes[
    sizeof(PakMenuFileName) == 30 ? 1 : -1];

extern PakMenuFileName D_800BAF08[];
extern PakMenuFileName *D_800BB0E8[];
extern unsigned char *D_8007726C;
extern unsigned char D_80093828[];

void func_800266BC(int *selection)
{
    unsigned int pages;
    unsigned char name[40];

    D_800BB128 = D_800BB0E8[*selection] - D_800BAF08;
    func_8004FB48(D_800BB128, &pages, name);
    func_800363D0(D_8007726C, D_80093828, name);
    D_800761F4 = 0;
    func_80026178(&D_8007726C, 0);
}
