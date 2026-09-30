#include "../../include/sdk_video_internal.h"

void osViSetMode(VideoMode *mode)
{
    register unsigned int mask;

    mask = func_80067560();
    D_8008F234->mode = mode;
    D_8008F234->state = 1;
    D_8008F234->control = D_8008F234->mode->control;
    func_80067580(mask);
}
