#include "../../include/session_setup_internal.h"

void func_8002EE38(SessionSetupCommand *command)
{
    SessionSetupAnimation *animation;
    int index;

    if (D_80077AD0->value1E == -1) {
        func_8001C49C(D_80093D18);
        func_8001C0D0(D_80093D20, D_80077AD0->value16);
    }
    if (D_80077AD0->value22 == -1) {
        func_8001C49C(D_80093D48);
        func_8001C0D0(D_80093D50, D_80077AD0->value16);
    }
    for (index = 0; index < 10; index++) {
        animation = D_80077AD0->entries[index];
        if (index == 0) {
            if (animation == 0) {
                func_8001C49C(D_80093D7C);
                func_8001C0D0(D_80093D84, D_80075A18);
            }
            if (animation->setup.kinemation.name == -1) {
                func_8001C49C(D_80093DA0);
                func_8001C0D0(D_80093DA8, D_80077AD0->value16);
            }
        }
    }
    if (D_800BB144 != 0) {
        D_80077AD4++;
    }
}
