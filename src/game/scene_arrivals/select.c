#include "../../../include/scene_commands_internal.h"
#include "../../../include/actor_resource_internal.h"
#include "../../../include/game_memory.h"

extern TextGlyphResource D_8009F560[];
int func_8003941C(int index);
void func_80021C14(int **destination, int *enabled, unsigned char *resource);

void func_80021C3C(int *output, int enabled)
{
    unsigned char category;
    int *selected[1];
    int amount;
    int index;
    int counts[10][36];
    void *resource;

    func_8003B694(counts, 0, sizeof(counts));
    /* Retail writes the first argument spill through this local indirection. */
    selected[0] = (int *)&output;
    for (index = 0; index < D_800B9A78.arrivalCount; index++) {
        resource = &D_800B9A78.arrivals[index];
        if (D_800B9A78.arrivals[index].state != 0) {
            category = ((SceneArrival *)resource)->category;
            amount = ((SceneArrival *)resource)->count;
            switch (category) {
            default:
                break;
            case 0:
            case 1:
            case 3:
            {
                switch (((SceneArrival *)resource)->trigger) {
                case 0:
                    amount += ((SceneArrival *)resource)->delay;
                    if (counts[category][((SceneArrival *)resource)->resourceIndex] < amount) {
                        counts[category][((SceneArrival *)resource)->resourceIndex] = amount;
                    }
                    break;
                case 2:
                    if (counts[category][((SceneArrival *)resource)->resourceIndex] < ((SceneArrival *)resource)->delay) {
                        counts[category][((SceneArrival *)resource)->resourceIndex] = ((SceneArrival *)resource)->delay;
                    }
                    break;
                case 1:
                case 3:
                case 4:
                case 5:
                default:
                    counts[category][((SceneArrival *)resource)->resourceIndex] += amount;
                    break;
                }
                break;
            }
            }
        }
    }
    func_80021C14(selected, &enabled, (unsigned char *)D_800AC998);
    if ((D_800B8F78.word00.value >> 31) != 0) {
        for (index = 0; index < 4; index++) {
            counts[3][index + 4] = counts[3][index] * 3;
        }
    }
    for (index = 17; index < 21; index++) {
        counts[0][index + 4] += counts[0][index] * D_800B14A4;
    }
    for (index = 9; index < 13; index++) {
        counts[0][index + 4] += counts[0][index] * D_800B00B0;
    }
    for (index = 0; index < 36; index++) {
        if (counts[0][index] != 0) {
            resource = &D_800AF1F0[index];
            if (func_8003941C(((ActorResource68Internal *)resource)->firstAnimation28->loopIndex) / 2 <= counts[0][index]) {
                func_80021C14(selected, &enabled, (unsigned char *)resource);
            }
        }
    }
    for (index = 0; index < 8; index++) {
        if (counts[3][index] != 0) {
            resource = &D_800ACE58[index];
            if (func_8003941C(((TextGlyphResource *)resource)->animation.tracks[0]->loopIndex) / 2 <= counts[3][index]) {
                func_80021C14(selected, &enabled, (unsigned char *)resource);
            }
        }
    }
    for (index = 0; index != 16; index++) {
        if (counts[1][index] != 0) {
            resource = &D_8009F560[index];
            if (func_8003941C(((TextGlyphResource *)resource)->animation.tracks[0]->loopIndex) / 2 <= counts[1][index]) {
                func_80021C14(selected, &enabled, (unsigned char *)resource);
            }
        }
    }
}
