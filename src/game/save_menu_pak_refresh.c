#include "../../include/save_menu_legacy_internal.h"

void func_80026674(int deleteSelected)
{
    if (deleteSelected != 0) {
        func_8004FA14(D_800BB128);
    }
    if (func_800267BC() != 1) {
        func_8002674C();
    }
}
