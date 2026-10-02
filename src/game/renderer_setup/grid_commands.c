#include "../../../include/renderer_setup_internal.h"

const FrameCommand D_8007CA70[11] = {
    RENDERER_SETUP_COMMAND(0xE7000000, 0),          /* Pipe sync. */
    RENDERER_SETUP_COMMAND(0xBA001402, 0),          /* One cycle. */
    RENDERER_SETUP_COMMAND(0xBA000801, 0),          /* Combine key disabled. */
    RENDERER_SETUP_COMMAND(0xB9000002, 0),          /* Alpha compare disabled. */
    RENDERER_SETUP_COMMAND(0xBA001001, 0x10000),    /* Texture LOD enabled. */
    RENDERER_SETUP_COMMAND(0xB900031D, 0x00552078), /* Render mode. */
    RENDERER_SETUP_COMMAND(0xBA000602, 0xC0),       /* Color dither disabled. */
    RENDERER_SETUP_COMMAND(0xFC127E24, 0xFFFFF9FC), /* Combine mode. */
    RENDERER_SETUP_COMMAND(0xBB000001, 0x80008000), /* Texture enabled, half scale. */
    RENDERER_SETUP_COMMAND(0xBA000C02, 0x2000),     /* Bilinear texture filtering. */
    RENDERER_SETUP_COMMAND(0xB8000000, 0)           /* End display list. */
};
