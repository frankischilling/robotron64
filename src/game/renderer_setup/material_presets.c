#include "../../../include/renderer_setup_internal.h"

const FrameCommand D_8007C5C0[6] = {
    RENDERER_SETUP_COMMAND(0xE7000000, 0x00000000), /* Pipe sync. */
    RENDERER_SETUP_COMMAND(0xBA001402, 0x00000000), /* Set RDP mode bits. */
    RENDERER_SETUP_COMMAND(0xB7000000, 0x00002001), /* Set geometry mode bits. */
    RENDERER_SETUP_COMMAND(0xB900031D, 0x00552078), /* Set render mode bits. */
    RENDERER_SETUP_COMMAND(0xFCFFFFFF, 0xFFFDF6FB), /* Set combine mode. */
    RENDERER_SETUP_COMMAND(0xB8000000, 0x00000000), /* End display list. */
};

const FrameCommand D_8007C5F0[7] = {
    RENDERER_SETUP_COMMAND(0xE7000000, 0x00000000), /* Pipe sync. */
    RENDERER_SETUP_COMMAND(0xBA001402, 0x00000000), /* Set RDP mode bits. */
    RENDERER_SETUP_COMMAND(0xBA001001, 0x00000000), /* Set RDP mode bits. */
    RENDERER_SETUP_COMMAND(0xB7000000, 0x00002001), /* Set geometry mode bits. */
    RENDERER_SETUP_COMMAND(0xB900031D, 0x00552078), /* Set render mode bits. */
    RENDERER_SETUP_COMMAND(0xFCFFFFFF, 0xFFFCF279), /* Set combine mode. */
    RENDERER_SETUP_COMMAND(0xB8000000, 0x00000000), /* End display list. */
};

const FrameCommand D_8007C628[7] = {
    RENDERER_SETUP_COMMAND(0xE7000000, 0x00000000), /* Pipe sync. */
    RENDERER_SETUP_COMMAND(0xBA001402, 0x00100000), /* Set RDP mode bits. */
    RENDERER_SETUP_COMMAND(0xBA001001, 0x00010000), /* Set RDP mode bits. */
    RENDERER_SETUP_COMMAND(0xB7000000, 0x00002001), /* Set geometry mode bits. */
    RENDERER_SETUP_COMMAND(0xB900031D, 0x0C192078), /* Set render mode bits. */
    RENDERER_SETUP_COMMAND(0xFC26A1FF, 0x1FFC923C), /* Set combine mode. */
    RENDERER_SETUP_COMMAND(0xB8000000, 0x00000000), /* End display list. */
};

const FrameCommand D_8007C660[7] = {
    RENDERER_SETUP_COMMAND(0xE7000000, 0x00000000), /* Pipe sync. */
    RENDERER_SETUP_COMMAND(0xBA001402, 0x00000000), /* Set RDP mode bits. */
    RENDERER_SETUP_COMMAND(0xBA001001, 0x00000000), /* Set RDP mode bits. */
    RENDERER_SETUP_COMMAND(0xB7000000, 0x00002001), /* Set geometry mode bits. */
    RENDERER_SETUP_COMMAND(0xB900031D, 0x00552078), /* Set render mode bits. */
    RENDERER_SETUP_COMMAND(0xFC11FE23, 0xFFFFF7FB), /* Set combine mode. */
    RENDERER_SETUP_COMMAND(0xB8000000, 0x00000000), /* End display list. */
};

const FrameCommand D_8007C698[7] = {
    RENDERER_SETUP_COMMAND(0xE7000000, 0x00000000), /* Pipe sync. */
    RENDERER_SETUP_COMMAND(0xBA001402, 0x00100000), /* Set RDP mode bits. */
    RENDERER_SETUP_COMMAND(0xBA001001, 0x00010000), /* Set RDP mode bits. */
    RENDERER_SETUP_COMMAND(0xB7000000, 0x00002001), /* Set geometry mode bits. */
    RENDERER_SETUP_COMMAND(0xB900031D, 0x0C192078), /* Set render mode bits. */
    RENDERER_SETUP_COMMAND(0xFC26A003, 0x1FFC93FB), /* Set combine mode. */
    RENDERER_SETUP_COMMAND(0xB8000000, 0x00000000), /* End display list. */
};

const FrameCommand D_8007C6D0[6] = {
    RENDERER_SETUP_COMMAND(0xE7000000, 0x00000000), /* Pipe sync. */
    RENDERER_SETUP_COMMAND(0xBA001402, 0x00000000), /* Set RDP mode bits. */
    RENDERER_SETUP_COMMAND(0xB7000000, 0x00022205), /* Set geometry mode bits. */
    RENDERER_SETUP_COMMAND(0xB900031D, 0x00552078), /* Set render mode bits. */
    RENDERER_SETUP_COMMAND(0xFCFFFFFF, 0xFFFE793C), /* Set combine mode. */
    RENDERER_SETUP_COMMAND(0xB8000000, 0x00000000), /* End display list. */
};

const FrameCommand D_8007C700[7] = {
    RENDERER_SETUP_COMMAND(0xE7000000, 0x00000000), /* Pipe sync. */
    RENDERER_SETUP_COMMAND(0xBA001402, 0x00000000), /* Set RDP mode bits. */
    RENDERER_SETUP_COMMAND(0xBA001001, 0x00000000), /* Set RDP mode bits. */
    RENDERER_SETUP_COMMAND(0xB7000000, 0x00022205), /* Set geometry mode bits. */
    RENDERER_SETUP_COMMAND(0xB900031D, 0x00552078), /* Set render mode bits. */
    RENDERER_SETUP_COMMAND(0xFC127E24, 0xFFFFF9FC), /* Set combine mode. */
    RENDERER_SETUP_COMMAND(0xB8000000, 0x00000000), /* End display list. */
};

const FrameCommand D_8007C738[7] = {
    RENDERER_SETUP_COMMAND(0xE7000000, 0x00000000), /* Pipe sync. */
    RENDERER_SETUP_COMMAND(0xBA001402, 0x00100000), /* Set RDP mode bits. */
    RENDERER_SETUP_COMMAND(0xBA001001, 0x00010000), /* Set RDP mode bits. */
    RENDERER_SETUP_COMMAND(0xB7000000, 0x00022205), /* Set geometry mode bits. */
    RENDERER_SETUP_COMMAND(0xB900031D, 0x0C192078), /* Set render mode bits. */
    RENDERER_SETUP_COMMAND(0xFC26A004, 0x1FFC93FC), /* Set combine mode. */
    RENDERER_SETUP_COMMAND(0xB8000000, 0x00000000), /* End display list. */
};

