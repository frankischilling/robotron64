#include "../../../include/scene_commands_internal.h"
#include "../../../include/actor_resource_internal.h"
#include "../../../include/game_memory.h"

extern TextGlyphResource D_8009F560[];
int func_8003941C(int index);
void func_80021C14(int **destination, int *enabled, unsigned char *resource);

void func_80021C3C(int *output, int enabled)
{
    int **selected;
    int counts[10][36];
    SceneArrival *arrival;
    unsigned char category;
    int amount;
    int index;
    void *resource;

    func_8003B694(counts, 0, sizeof(counts));
    /* Retail writes the first argument spill through this local indirection. */
    selected = &output;
    for (index = 0; index < D_800B9A78.arrivalCount; index++) {
        arrival = &D_800B9A78.arrivals[index];
        if (D_800B9A78.arrivals[index].state != 0) {
            category = arrival->category;
            amount = arrival->count;
            if (category == 0 || category == 1 || category == 3) {
                switch (arrival->trigger) {
                case 0:
                    amount += arrival->delay;
                    if (counts[category][arrival->resourceIndex] < amount) {
                        counts[category][arrival->resourceIndex] = amount;
                    }
                    break;
                case 2:
                    if (counts[category][arrival->resourceIndex] < arrival->delay) {
                        counts[category][arrival->resourceIndex] = arrival->delay;
                    }
                    break;
                case 1:
                case 3:
                case 4:
                case 5:
                default:
                    counts[category][arrival->resourceIndex] += amount;
                    break;
                }
            }
        }
    }
    func_80021C14((int **)&selected, &enabled, (unsigned char *)D_800AC998);
    if ((D_800B8F78.word00.value >> 31) != 0) {
        counts[3][4] = counts[3][0] * 3;
        counts[3][5] = counts[3][1] * 3;
        counts[3][6] = counts[3][2] * 3;
        counts[3][7] = counts[3][3] * 3;
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
                func_80021C14((int **)&selected, &enabled, (unsigned char *)resource);
            }
        }
    }
    for (index = 0; index < 8; index++) {
        if (counts[3][index] != 0) {
            resource = &D_800ACE58[index];
            if (func_8003941C(((TextGlyphResource *)resource)->animation.tracks[0]->loopIndex) / 2 <= counts[3][index]) {
                func_80021C14((int **)&selected, &enabled, (unsigned char *)resource);
            }
        }
    }
    for (index = 0; index != 16; index++) {
        if (counts[1][index] != 0) {
            resource = &D_8009F560[index];
            if (func_8003941C(((TextGlyphResource *)resource)->animation.tracks[0]->loopIndex) / 2 <= counts[1][index]) {
                func_80021C14((int **)&selected, &enabled, (unsigned char *)resource);
            }
        }
    }
}
