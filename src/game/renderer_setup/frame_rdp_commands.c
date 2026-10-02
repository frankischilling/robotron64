#include "../../../include/renderer_setup_internal.h"

const FrameCommand D_8007CB58[16] = {
    RENDERER_SETUP_COMMAND(0xED000000, 0x005003C0), /* Scissor: 320 by 240. */
    RENDERER_SETUP_COMMAND(0xFCFFFFFF, 0xFFFE793C), /* Combine mode. */
    RENDERER_SETUP_COMMAND(0xBA001001, 0),          /* Tile LOD. */
    RENDERER_SETUP_COMMAND(0xBA000E02, 0),          /* Texture LUT disabled. */
    RENDERER_SETUP_COMMAND(0xBA001102, 0),          /* Detail clamp. */
    RENDERER_SETUP_COMMAND(0xBA001301, 0x80000),    /* Perspective correction enabled. */
    RENDERER_SETUP_COMMAND(0xBA000C02, 0x2000),     /* Bilinear texture filtering. */
    RENDERER_SETUP_COMMAND(0xBA000903, 0xC00),      /* Filtered texture conversion. */
    RENDERER_SETUP_COMMAND(0xBA000801, 0),          /* Combine key disabled. */
    RENDERER_SETUP_COMMAND(0xB9000002, 0),          /* Alpha compare disabled. */
    RENDERER_SETUP_COMMAND(0xB900031D, 0x0F0A4000), /* Render mode. */
    RENDERER_SETUP_COMMAND(0xC0000000, 0),          /* No-op. */
    RENDERER_SETUP_COMMAND(0xBA000602, 0x80),       /* Noise color dither. */
    RENDERER_SETUP_COMMAND(0xBA001402, 0),          /* One cycle. */
    RENDERER_SETUP_COMMAND(0xE7000000, 0),          /* Pipe sync. */
    RENDERER_SETUP_COMMAND(0xB8000000, 0)           /* End display list. */
};
