#include "../../include/session_menu_internal.h"

void func_8002F804(void)
{
    SessionMenuPreview *preview;
    int index;

    for (index = 0; index < 2; index++) {
        preview = &D_80077AE0[index];
        if (preview->firstActor != 0) {
            preview->firstActor->state = 2;
            preview->firstActor = 0;
        }
        if (preview->secondActor != 0) {
            preview->secondActor->state = 2;
            preview->secondActor = 0;
        }
    }
}
