#ifndef ROBOTRON_FRAME_SLOT_H
#define ROBOTRON_FRAME_SLOT_H

/* Shared prefix at actor offsets 0x4C and 0x50. */
typedef struct FrameSlotState {
    unsigned char unknown00[0x4C];
    int value4C;
    int index50;
} FrameSlotState;

typedef char FrameSlotStateMustBe84Bytes[
    sizeof(FrameSlotState) == 0x54 ? 1 : -1];

extern unsigned char D_8008D4AC[20];

void func_8004E7D4(FrameSlotState *state);

#endif
