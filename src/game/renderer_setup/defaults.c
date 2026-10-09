#include "../../../include/graphics_state_internal.h"

int D_8007D5D8 = -1;
int D_8007D5DC = 70;
int D_8007D5E0 = 50;
int D_8007D5E4 = -70;

/* Fixed RSP/RDP setup, ending at the first end-display-list packet. */
FrameCommand D_8007D5E8[23] = {
    {{0xE7000000, 0x00000000}}, /* pipe sync */
    {{0xB6000000, 0x001F3204}}, /* clear geometry modes */
    {{0xBB000001, 0x07C007C0}}, /* texture scale */
    {{0xB7000000, 0x00022205}}, /* set geometry modes */
    {{0xB7000000, 0x00040000}},
    {{0xBA001402, 0x00000000}}, /* one-cycle pipeline */
    {{0xBA001701, 0x00000000}}, /* non-pipeline primitive mode */
    {{0xED000000, 0x005003C0}}, /* scissor: (0, 0)..(320, 240) */
    {{0xFCFFFFFF, 0xFFFCF87C}}, /* combine mode */
    {{0xB900031D, 0x00552078}}, /* render mode */
    {{0xBA000602, 0x00000000}}, /* color dither */
    {{0xBA001301, 0x00080000}}, /* perspective texture coordinates */
    {{0xBA001001, 0x00000000}}, /* tile texture LOD */
    {{0xBA000C02, 0x00002000}}, /* bilinear filter */
    {{0xBB000001, 0x07C007C0}},
    {{0xFD100000, (unsigned int)D_8007CDD8}}, /* RGBA, 16-bit image */
    {{0xF5100000, 0x07014050}}, /* load tile */
    {{0xE6000000, 0x00000000}}, /* load sync */
    {{0xF3000000, 0x073FF100}}, /* 1,024 texels */
    {{0xE7000000, 0x00000000}},
    {{0xF5101000, 0x00014050}}, /* render tile, eight-word line */
    {{0xF2000000, 0x0007C07C}}, /* 32 by 32 tile */
    {{0xB8000000, 0x00000000}}
};
