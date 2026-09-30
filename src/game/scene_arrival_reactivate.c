#include "../../include/scene_definition.h"

extern int D_800BA740;

void func_80020F24(void)
{
    int index;
    SceneArrival *arrival;

    for (index = 0; index < D_800BA740; index++) {
        arrival = &D_800B9A78.arrivals[index];
        if (D_800B9A78.arrivals[index].state == 2 && arrival->trigger == 5) {
            arrival->state = 1;
        }
    }
}
