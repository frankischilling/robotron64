#include "../../include/movie.h"
#include "../../include/text.h"

typedef struct SceneMenuStringChoice {
    unsigned char *text;
    int value;
    int slot;
} SceneMenuStringChoice;

typedef char SceneMenuStringChoiceMustBe12Bytes[
    sizeof(SceneMenuStringChoice) == 12 ? 1 : -1];

extern SceneMenuStringChoice D_800761AC[][2];
extern int D_8009EFB0;
extern unsigned char D_800925E8[];

void func_80022A08(void)
{
    int slot;
    int choice;
    int found;

    for (slot = 0; slot != 5; slot++) {
        found = 0;
        for (choice = 0; choice != 2; choice++) {
            if (D_800761AC[D_8009EFB0][choice].text != 0 &&
                D_800761AC[D_8009EFB0][choice].slot == slot) {
                func_80000518(D_800761AC[D_8009EFB0][choice].text);
                func_80000F48(D_800B14A8->strings[slot].field04,
                             D_800761AC[D_8009EFB0][choice].text);
                found = 1;
                D_800B14A8->strings[slot].field18 =
                    D_800761AC[D_8009EFB0][choice].value;
            }
        }
        if (!found) {
            func_80000F48(D_800B14A8->strings[slot].field04, D_800925E8);
        }
    }
}
