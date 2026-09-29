#include "../../include/early_game_state.h"
#include "../../include/object_helpers.h"
#include "../../include/save_game.h"

extern int D_80073864;
extern int D_80073884;
extern int D_80073888;
extern int D_8007388C;
extern int D_80073890;
extern int D_8009EFA0;
extern int D_800AD168;
extern int D_8013D9B0;

extern float D_FLT_8009746C;
extern float D_FLT_80097470;
extern float D_FLT_80097474;
extern float D_FLT_80097478;
extern float D_FLT_8009747C;
extern float D_FLT_80097480;
extern float D_FLT_80097484;
extern float D_FLT_80097488;
extern float D_FLT_8009748C;
extern float D_FLT_80097490;
extern float D_FLT_80097494;
extern float D_FLT_80097498;

extern int D_800AE560;
extern float D_FLT_8008FBE8;
extern float D_FLT_8008FBEC;
extern int D_8009743C;

extern int func_80039EA0(int object, int value);
extern void func_80039F10(float x, float y, float z);
extern void func_80039FCC(int x, int y, int z);
extern void func_8003A4EC(void);
extern float func_8004CE70(float value);

void func_8001276C(int advance, int unused)
{
    int value;

    if (D_800AD284 == 0) {
        D_8013D9B0 = D_8009EFA0;
        D_FLT_80097484 = D_FLT_8009746C;
        D_FLT_80097488 = D_FLT_80097470;
        D_FLT_8009748C = D_FLT_80097474;
        D_FLT_80097490 = D_FLT_80097478;
        D_FLT_80097494 = D_FLT_8009747C;
        D_FLT_80097498 = D_FLT_80097480;
        D_80073890 = 20;
        if (advance != 0) {
            D_8007388C++;
            value = (&D_80073864)[D_8007388C];
            if (value == 0) {
                D_8007388C = 0;
                value = (&D_80073864)[D_8007388C];
            }
            D_8009B190[D_800AD168].saved.selection05 = (unsigned char)value;
            D_80073888 = 1;
            D_80073884 = 0;
        }
    }
}

void func_8001288C(int unused)
{
    func_80039EA0(D_800AE560, 1);
    func_80039F10(0.0f, D_FLT_8008FBE8, 0.0f);
    func_80039FCC(0, 0, 0);
    func_8003A24C(1.0f, 1.0f, 1.0f);
    func_8003A1E4(500.0f);
    func_8003A240(func_8004CE70(D_FLT_8008FBEC));
    func_8003A4EC();
    D_FLT_800C8BD0 = 0.0f;
    D_800C8BD4 = 0;
    D_800C8BD5 = 0;
    D_800C8BD6 = 0;
    D_8009743C = 0;
}
