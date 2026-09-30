#include "../../include/scheduler.h"

extern int D_8008E3D0;
extern OSMesgQueue *D_8008E3D8;

OSMesgQueue *func_8006B570(void)
{
    if (!D_8008E3D0) {
        return 0;
    }
    return D_8008E3D8;
}
