#include "../../include/save_menu_legacy_internal.h"
#include "../../include/controller_services.h"
#include "../../include/controller_pak_menu_internal.h"
#include "../../include/pak_confirmation_internal.h"

void func_800266BC(int *selection)
{
    unsigned int pages;
    unsigned char name[40];

    D_800BB128 = D_800BB0E8[*selection] - D_800BAF08;
    func_8004FB48(D_800BB128, &pages, name);
    func_800363D0(D_8007726C[0].page.title00, (unsigned char *)D_80093828, name);
    D_800761F4 = 0;
    func_80026178(D_8007726C, 0);
}
