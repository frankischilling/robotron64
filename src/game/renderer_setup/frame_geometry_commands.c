#include "../../../include/renderer_setup_internal.h"

const FrameCommand D_8007CB18[8] = {
    RENDERER_SETUP_COMMAND(0x03800010, &D_8007CAC8), /* Viewport. */
    RENDERER_SETUP_COMMAND(0xB6000000, 0x001F3205), /* Clear geometry modes. */
    RENDERER_SETUP_COMMAND(0xBB000000, 0),          /* Texture disabled. */
    RENDERER_SETUP_COMMAND(0xB7000000, 4),          /* Shading enabled. */
    RENDERER_SETUP_COMMAND(0xBC000002, 0x80000040), /* One directional light. */
    RENDERER_SETUP_COMMAND(0x03860010, &D_8007CB08), /* Directional light. */
    RENDERER_SETUP_COMMAND(0x03880010, &D_8007CB00), /* Ambient light. */
    RENDERER_SETUP_COMMAND(0xB8000000, 0)           /* End display list. */
};
