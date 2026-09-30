#ifndef ROBOTRON_DEBUG_TEXT_INTERNAL_H
#define ROBOTRON_DEBUG_TEXT_INTERNAL_H

/* Known font prefix; the character drawer reads the advance at offset 0x0C. */
typedef struct DebugTextFont {
    int unknown00[3];
    int advance;
} DebugTextFont;

extern int D_800AE2FC;

int func_80037408(int context);
void func_80037420(unsigned char *text, int x, int y, DebugTextFont *font);

#endif
