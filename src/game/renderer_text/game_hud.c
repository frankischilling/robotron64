#include "../../../include/graphics_state_internal.h"
#include "../../../include/renderer_debug_text.h"
#include "../../../include/renderer_image_setup_internal.h"

extern int D_8007D91C;
extern int D_80138250;
extern int D_800AD1C8;
extern unsigned char D_80075F30[];
extern unsigned char D_8008D340[];
extern unsigned char D_8008CB40[];
extern unsigned int D_8009EFA0;
extern unsigned int D_8009EFA4;
extern unsigned int D_8013D9B0;
unsigned char *func_800126E0(void);
int func_8003CC58(int angle);
/* Nonmatching candidate; see docs/renderer-diagnostics-and-text.md. */
void func_800493F4(int value);
void func_80049DB0(void);
void func_80049DF4(int red, int green, int blue);
void func_80049E10(int value);

void func_8004B590(int score, int level, int lives, int value3, int value4,
                  int value5, int powers, int secondScore, int secondLevel,
                  int secondLives, int value10, int value11, int value12,
                  int value13, int players)
{
    int lifeX;
    int x;
    int i;
    int count;
    unsigned char digits[24];
    unsigned char *message;
    unsigned char character;

    lives--;
    secondLives--;
    if (lives < 0) lives = 0;
    if (secondLives < 0) secondLives = 0;
    FRAME_COMMAND(0xE7000000, 0);
    func_80048D9C();
    func_800493F4(400);
    func_80049BAC();
    func_80049E10(64);
    func_80049DF4(0, 0, 255);
    if (players == 2) {
        func_8004B4F8(score, 95, 76);
        func_8004B45C(secondScore, -95, 76);
    } else {
        func_8004B45C(score, 10, 76);
    }
    x = -80;
    if (D_8007D91C != 0) {
        count = func_8004B2E0(D_80138250, digits);
        for (i = count - 1; i >= 0; i--) {
            func_80049DD8(x, 60, 200);
            func_80049E3C(digits[i] + '0');
            x -= 8;
        }
    }
    x = 20;
    if (D_800AD1C8 != 0) {
        count = (level + 999) / 1000;
        for (i = 0, lifeX = 100; i < count; i++) {
            func_80049DD8(lifeX, -78, 200);
            func_80049E3C(31);
            lifeX -= 8;
        }
    } else {
        for (i = 0; i < 5; i++) {
            if ((1 << i) & powers) {
                if (powers == 31) {
                    func_80049DF4(255, 255, 0);
                    func_80049E10(func_8003CC58(D_8009EFA4 * 2) * 20 / 4096 + 60);
                } else {
                    func_80049DF4(0, 0, 255);
                    func_80049E10(func_8003CC58(D_8009EFA4 + i * 600) * 20 / 4096 + 60);
                }
                func_80049DD8(x * 2, -78, 200);
                func_80049E3C(D_80075F30[i]);
            }
            x -= 6;
        }
        if (players == 2) {
            func_80049E10(51);
            func_80049DF4(255, 0, 0);
            x = 95;
            for (i = 0; i < 4; i++) {
                func_80049DD8(x, -78, 200);
                func_80049E3C(D_8008D340[i]);
                x -= 8;
            }
            func_80049E10(64);
            func_80049DF4(0, 0, 255);
            func_8004B4F8(level, x - 4, -78);
            func_80049E10(51);
            func_80049DF4(255, 0, 0);
            x = -36;
            for (i = 0; i < 4; i++) {
                func_80049DD8(x, -78, 200);
                func_80049E3C(D_8008D340[i]);
                x -= 8;
            }
            func_80049E10(64);
            func_80049DF4(0, 0, 255);
            func_8004B4F8(secondLevel, x - 4, -78);
        } else {
            func_80049E10(51);
            func_80049DF4(255, 0, 0);
            x = -40;
            for (i = 0; i < 4; i++) {
                func_80049DD8(x, -78, 200);
                func_80049E3C(D_8008D340[i]);
                x -= 8;
            }
            func_80049E10(64);
            func_80049DF4(0, 0, 255);
            func_8004B4F8(level, x - 4, -78);
        }
        if (D_8009EFA0 - D_8013D9B0 < 5000) {
            if (players == 2) x = 20;
            else x = 100;
            message = func_800126E0();
            while ((character = *message++) != 0) {
                func_80049DD8(x, -78, 200);
                func_80049E3C(character);
                x -= 8;
            }
        }
    }
    if (players == 2) {
        func_80049E10(32);
        func_80049DD8(83, 64, 200);
        func_80049E3C('X');
        func_80049E10(64);
        func_8004B4F8(lives, 71, 64);
        func_80049E10(32);
        func_80049DD8(-80, 64, 200);
        func_80049E3C('X');
        func_80049E10(64);
        func_8004B4F8(secondLives, -92, 64);
    } else {
        func_80049E10(32);
        func_80049DD8(-84, 76, 200);
        func_80049E3C('X');
        func_80049E10(64);
        func_8004B4F8(lives, -96, 76);
    }
    if (players == 2) {
        func_80049E10(64);
        func_80049DD8(95, 64, 200);
        func_8004AFA4(D_8008CB40);
        func_80049DD8(-68, 64, 200);
        func_8004AFA4(D_8008CB40);
    } else {
        func_80049E10(64);
        func_80049DD8(-72, 76, 200);
        func_8004AFA4(D_8008CB40);
    }
    func_80049DB0();
}
