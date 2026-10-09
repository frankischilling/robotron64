#include "../../../include/graphics_state_internal.h"

/* The tile-origin caller changes the tile rectangle after invoking this list. */
FrameCommand D_8007C970[16] = {
    {{0xE7000000, 0x00000000}}, /* pipe sync */
    {{0xFA000000, 0xAFAFAF12}}, /* primitive color */
    {{0xBA001402, 0x00000000}}, /* one-cycle pipeline */
    {{0xBA001001, 0x00000000}}, /* tile texture LOD */
    {{0xB7000000, 0x00062001}}, /* geometry modes */
    {{0xB900031D, 0x00552078}}, /* render mode */
    {{0xFC30FE61, 0x44FE7339}}, /* combine mode */
    {{0xBB000001, 0x07C007C0}}, /* texture scale */
    {{0xFD900000, (unsigned int)D_8007C770}}, /* intensity, 16-bit load view */
    {{0xF5900000, 0x07014050}}, /* load tile */
    {{0xE6000000, 0x00000000}}, /* load sync */
    {{0xF3000000, 0x070FF400}}, /* 256 halfwords */
    {{0xE7000000, 0x00000000}},
    {{0xF5800400, 0x00014050}}, /* intensity, 4-bit render tile */
    {{0xF2000000, 0x0007C07C}}, /* 32 by 32 tile */
    {{0xB8000000, 0x00000000}}
};
