#include "../../include/sdk_pi_dma.h"

OSMesgQueue *func_8006B570(void)
{
    if (!D_8008E3D0.active) {
        return 0;
    }
    return D_8008E3D0.commandQueue;
}
