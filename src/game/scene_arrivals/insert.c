#include "../../../include/scene_commands_internal.h"
#include "../../../include/actor_resource_internal.h"
#include "../../../include/game_memory.h"
#include "../../../include/error_formatters.h"

void func_8001FCE4(int replace, int category, int resourceIndex,
                  int trigger, int delay, unsigned int count, int x, int y)
{
    int other;
    int index;
    int end;
    int coordinate;
    SceneArrival *arrival;
    int state = 1;

    if (trigger == 4) {
        trigger = 1;
        if (delay < 100) {
            delay = 100;
        }
        delay = (func_8004CDE8() >> 3) % (delay / 100);
    } else if (trigger == 1) {
        delay /= 100;
    }
    if (count > 0x7FFF || (unsigned int)delay > 0x7FFF) {
        func_8001C0D0((unsigned char *)D_800917F8);
    }
    if (count == 0) {
        return;
    }

    if (replace) {
        for (index = 0; index < D_800B9A78.arrivalCount; index++) {
            if (D_800B9A78.arrivals[index].state == 0) {
                break;
            }
            if (category == D_800B9A78.arrivals[index].category &&
                resourceIndex == D_800B9A78.arrivals[index].resourceIndex) {
                for (end = index + 1; end < D_800B9A78.arrivalCount; end++) {
                    if (D_800B9A78.arrivals[end].state == 0) {
                        break;
                    }
                }
                func_8003B594(&D_800B9A78.arrivals[index + 1],
                              &D_800B9A78.arrivals[index],
                              (end - index) * sizeof(SceneArrival));
                if (end == D_800B9A78.arrivalCount) {
                    D_800B9A78.arrivalCount++;
                }
                break;
            }
        }
        for (other = index + 1; other < D_800B9A78.arrivalCount; other++) {
            if (category == D_800B9A78.arrivals[other].category &&
                resourceIndex == D_800B9A78.arrivals[other].resourceIndex &&
                D_800B9A78.arrivals[other].state == 1) {
                D_800B9A78.arrivals[other].state = 2;
            }
        }
    } else {
        for (index = 0; index < D_800B9A78.arrivalCount; index++) {
            if (D_800B9A78.arrivals[index].state == 0) {
                break;
            }
        }
        for (other = 0; other < index; other++) {
            if (D_800B9A78.arrivals[other].state != 0 &&
                category == D_800B9A78.arrivals[other].category &&
                resourceIndex == D_800B9A78.arrivals[other].resourceIndex) {
                state = 2;
                break;
            }
        }
    }

    if (index == D_800B9A78.arrivalCount) {
        D_800B9A78.arrivalCount++;
    }
    arrival = &D_800B9A78.arrivals[index];
    if (state == 1 && trigger == 1 && delay == 0) {
        if (category == 0) {
            delay = D_800AF1F0[resourceIndex].arrivalDelay / 100;
        } else if (category == 3) {
            delay = 10;
        }
    }
    if (D_800B9A78.arrivalCount > 256) {
        D_800B9A78.arrivalCount--;
        func_8001C2C4(D_80091814);
        return;
    }

    coordinate = x;
    arrival->state = state;
    arrival->category = category;
    arrival->resourceIndex = resourceIndex;
    arrival->trigger = trigger;
    arrival->delay = delay;
    arrival->count = count;
    if (coordinate == -1) {
        arrival->x = coordinate;
    } else {
        arrival->x = coordinate / 256;
    }
    coordinate = y;
    if (coordinate == -1) {
        arrival->y = coordinate;
    } else {
        arrival->y = coordinate / 256;
    }
}
