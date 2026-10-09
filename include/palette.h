#ifndef ROBOTRON_PALETTE_H
#define ROBOTRON_PALETTE_H

typedef struct PaletteColor {
    unsigned char red;
    unsigned char green;
    unsigned char blue;
    unsigned char unused;
} PaletteColor;

typedef char PaletteColorMustBe4Bytes[sizeof(PaletteColor) == 4 ? 1 : -1];

#define PALETTE_COLOR_COUNT 256

extern PaletteColor D_8007BB34[PALETTE_COLOR_COUNT];
extern int D_8007BF34[PALETTE_COLOR_COUNT];
extern unsigned short D_8007D6D0[];

int func_8003BFEC(int red, int green, int blue);
void func_8003C020(PaletteColor *colors, int start, int count);
void func_8003C0DC(PaletteColor *color, int index);
void func_8003C14C(PaletteColor *color, int index);

#endif
