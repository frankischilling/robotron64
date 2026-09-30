#include "../../include/session_menu_internal.h"

void func_8002F638(int *selection)
{
    SessionMenuPreview *preview;
    int index;

    D_800BB150 = D_8009B190[0].saved.field34;
    D_800BB154 = D_8009B190[1].saved.field34;
    func_80026178(D_800771E8, 0);
    for (index = 0; index < 2; index++) {
        preview = &D_80077AE0[index];
        if (preview->firstResource != 0 && preview->firstActor == 0) {
            preview->firstActor = func_800283D4(
                9, &D_800B1BE8[preview->firstResource], preview->position);
            if (preview->firstActor != 0) {
                func_800396F4(preview->firstActor->objectIndex, 600);
                func_80039514(preview->firstActor->objectIndex, 800);
            }
        }
        if (preview->secondResource != 0 && preview->secondActor == 0) {
            preview->secondActor = func_800283D4(
                9, &D_800B1BE8[preview->secondResource], preview->position);
            if (preview->secondActor != 0) {
                func_80039514(preview->secondActor->objectIndex, 600);
                func_800396F4(preview->secondActor->objectIndex, 800);
            }
        }
    }
    func_8002F4D0(&D_8009B190[0].saved.field34);
}
