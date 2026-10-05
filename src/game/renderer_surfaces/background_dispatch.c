#include "../../../include/fixed_math.h"
#include "../../../include/scalar_math.h"
#include "../../../include/game_memory.h"
#include "../../../include/palette_effects.h"
#include "../../../include/renderer_color_wave_internal.h"
#include "../../../include/scene_background_internal.h"

extern FixedMatrix D_800CD250;
extern int D_8007CCA0, D_800AD280;
void func_800493F4(int value);
void func_80040560(int mode);
void func_80040BA0(int horizontal, int vertical);
void func_8000B5AC(void);

void func_800400D0(void)
{
    int blueAngle;
    int blueSine;
    int blueLevel;
    int greenAngle;
    int greenSine;
    int greenLevel;
    int redAngle;
    int redSine;
    int redLevel;
    int amplitude;
    FixedMatrix snapshot;
    int secondRed;
    int secondGreen;
    int secondBlue;
    int firstRed;
    int firstBlue;
    int firstGreen;

    func_8004CEF0(D_8009E578);
    secondRed = 0;
    secondGreen = 0;
    secondBlue = 0;
    func_8003B520(&snapshot, &D_800CD250, sizeof(snapshot));
    func_80048D9C();
    func_800493F4(400);
    func_8004729C(2);
    D_800CD2B4.time += D_8009EF94;
    if ((D_8007CCA0 != 0) && (D_800AD280 == 9)) {
        D_8007CCA8 = 19200;
        D_8007CCAC = 11000;
    } else {
        D_8007CCA8 = 19200;
        D_8007CCAC = 14400;
    }
    switch (D_8007CCB0) {
    case 0:
        amplitude = 30;
        blueAngle = (int) (D_800CD2B4.time * 8) / 2;
        blueSine = func_8004DB88(blueAngle);
        blueLevel = ((blueSine * amplitude) >> 15) + 64;
        firstBlue = blueLevel;
        greenAngle = (int) (D_800CD2B4.time * 8) / 5;
        greenSine = func_8004DB88(greenAngle);
        greenLevel = ((greenSine * amplitude) >> 15) + 64;
        firstGreen = greenLevel;
        redAngle = (int) (D_800CD2B4.time * 8) / 3;
        redSine = func_8004DB88(redAngle);
        redLevel = ((redSine * amplitude) >> 15) + 64;
        firstRed = redLevel;
        secondBlue = 255;
        break;
    case 1:
        amplitude = 30;
        blueAngle = (int) D_800CD2B4.time / 2;
        blueSine = func_8004DB88(blueAngle);
        blueLevel = ((blueSine * amplitude) >> 15) + 64;
        firstBlue = blueLevel;
        greenAngle = D_800CD2B4.time + 512;
        greenSine = func_8004DB88(greenAngle);
        greenLevel = ((greenSine * amplitude) >> 15) + 64;
        firstGreen = greenLevel;
        redAngle = (int) D_800CD2B4.time / 3;
        redSine = func_8004DB88(redAngle);
        amplitude = 14;
        redLevel = ((redSine * amplitude) >> 15) + 32;
        firstRed = redLevel;
        break;
    case 2:
        firstRed = D_800ACE18;
        firstGreen = D_800ACE24;
        firstBlue = D_800ACE34;
        secondRed = D_800ACE1C;
        secondGreen = D_800ACE2C;
        secondBlue = D_800ACE40;
        break;
    }
    switch (func_8004CEF0(D_8007BB18)) {
    case 0:
        func_80041B24(firstRed, firstGreen, firstBlue, secondRed, secondGreen, secondBlue);
        break;
    case 1:
        func_80040560(0);
        break;
    case 2:
        func_80040BA0(5, 5);
        break;
    case 3:
        func_80040BA0(10, 4);
        break;
    case 4:
        func_80040F5C(firstRed, firstGreen, firstBlue, secondRed, secondGreen, secondBlue, 0);
        break;
    case 5:
        func_80041180(firstRed, firstGreen, firstBlue, secondRed, secondGreen, secondBlue);
        break;
    case 6:
        func_80040560(1);
        break;
    case 7:
        func_8000B5AC();
        break;
    case 8:
        func_80040F5C(firstRed, firstGreen, firstBlue, secondRed, secondGreen, secondBlue, 1);
        break;
    case 9:
        func_80041180(255, 255, 255, 255, 255, 255);
        break;
    case 10:
        func_80041180(0, 0, 0, 0, 0, 0);
        break;
    }
    func_80049514();
    func_8003B520(&D_800CD250, &snapshot, sizeof(snapshot));
}
