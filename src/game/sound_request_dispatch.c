#include "../../include/sound_bridge_internal.h"
static const unsigned char D_800942C0[] = "%d is a wrong sound handle!\n";
void func_8003BF9C();
void func_8003BF94();
int func_8003614C(int sound, int mode, int value, int extra)
{
    if (sound < 0 || sound >= 117) {
        func_8001C2C4((unsigned char *)D_800942C0, sound);
        return 0;
    }
    if (D_800AE568[sound].platformFlag != 0) {
        func_8003BF9C(sound);
    }
    if (mode == 0) {
        func_800515B0(sound, value);
    } else {
        func_8003BF94(sound, mode, value);
    }
    return 1;
}
