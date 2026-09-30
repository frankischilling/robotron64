typedef struct FrameSlotState {
    unsigned char unknown00[0x4C];
    int value4C;
    int index50;
} FrameSlotState;

extern unsigned char D_8008D4AC[20];

void func_8004E7D4(FrameSlotState *state)
{
    int index;

    state->value4C = 0;
    state->index50 = 0;
    for (index = 0; index < 20; index++) {
        if (D_8008D4AC[index] == 0) {
            break;
        }
    }
    if (index != 20) {
        D_8008D4AC[index] = 1;
        state->index50 = index;
    }
}
