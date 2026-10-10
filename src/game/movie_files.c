#include "../../include/movie.h"
#include "../../include/movie_literals.h"
#include "../../include/game_memory.h"
#include "../../include/text.h"

void *func_8003C64C(unsigned char *name, int *size);
void func_8003C698();

int func_80003A7C(int identifier, unsigned char *name)
{
    unsigned char path[256];
    void *data;
    int index;
    int found = 0;
    MovieTrackState *candidate;
    MovieTrackState *freeCandidate;
    int size;
    unsigned char filename[64];

    candidate = D_800B00B8;
    for (index = 0; index < MOVIE_TRACK_COUNT; index++, candidate++) {
        if (candidate->active && identifier == candidate->identifier) {
            return index;
        }
    }
    func_8003B6E4(path, D_8008F8B0);
    func_8003B734(path, name);
    if (func_8003B4C0(path, '.')) {
        func_8003B6E4(func_8003B4C0(path, '.'), D_8008F8B8);
    } else {
        func_8003B734(path, D_8008F8C0);
    }
    freeCandidate = D_800B00B8;
    for (index = 0; index != MOVIE_TRACK_COUNT; index++, freeCandidate++) {
        if (freeCandidate->active == 0) {
            found = 1;
            break;
        }
    }
    if (found == 0) {
        func_8001C0D0(D_8008F8C8);
    }
    D_800972A0 = &D_800B00B8[index];
    func_8003B6E4(filename, path);
    func_8003B6E4(func_8003B4C0(filename, '.'), D_8008F8E0);
    data = func_8003C64C(filename, &size);
    func_8003B520(D_800972A0, data, sizeof(MovieTrackState));
    func_8003C698(data);
    if (D_800972A0->integerChannelCount != 0) {
        func_8003B6E4(filename, path);
        func_8003B6E4(func_8003B4C0(filename, '.'), D_8008F8E8);
        D_800972A0->integerChannels = func_8003C64C(filename, &size);
    }
    if (D_800972A0->floatChannelCount != 0) {
        func_8003B6E4(filename, path);
        func_8003B6E4(func_8003B4C0(filename, '.'), D_8008F8F0);
        D_800972A0->floatChannels = func_8003C64C(filename, &size);
    }
    D_800972A0->active = 1;
    D_800972A0->identifier = identifier;
    return index;
}

void func_80003CF8(int index)
{
    D_800B00B8[index].active = 0;
    if (D_800B00B8[index].integerChannelCount != 0) {
        func_8003C698(D_800B00B8[index].integerChannels);
    }
    if (D_800B00B8[index].floatChannelCount != 0) {
        func_8003C698(D_800B00B8[index].floatChannels);
    }
}
