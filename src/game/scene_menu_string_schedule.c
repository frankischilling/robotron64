#include "../../include/movie.h"
#include "../../include/text.h"

typedef struct SceneMenuStringChoice {
    unsigned char *text;
    int value;
    int slot;
} SceneMenuStringChoice;

typedef char SceneMenuStringChoiceMustBe12Bytes[
    sizeof(SceneMenuStringChoice) == 12 ? 1 : -1];

extern SceneMenuStringChoice D_80076014[][2];
extern int D_8009EFA8;
extern unsigned char D_800925E4[];
extern int D_800B6FEC;
void func_800227F4(int unused);

void func_80022858(void)
{
    int slot;
    int choice;
    int found;

    D_800B6FEC = 1;
    for (slot = 0; slot != 5; slot++) {
        found = 0;
        for (choice = 0; choice != 2; choice++) {
            if (D_80076014[D_8009EFA8][choice].text != 0 &&
                D_80076014[D_8009EFA8][choice].slot == slot) {
                func_80000518(D_80076014[D_8009EFA8][choice].text);
                func_80000F48(D_800B14A8->strings[slot].field04,
                             D_80076014[D_8009EFA8][choice].text);
                found = 1;
                D_800B14A8->strings[slot].field18 =
                    D_80076014[D_8009EFA8][choice].value;
            }
        }
        if (!found) {
            func_80000F48(D_800B14A8->strings[slot].field04, D_800925E4);
        }
    }
    func_8000440C(func_800227F4, D_800B14A8->field2C * 3 / 4);
}
