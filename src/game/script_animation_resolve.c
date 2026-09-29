#include "../../include/actor_resource_internal.h"
#include "../../include/game_memory.h"
#include "../../include/resource_strings.h"

extern unsigned char D_800906D0[];
extern unsigned char D_800906D8[];
extern unsigned char D_800906E0[];
extern unsigned char D_800906E8[];

void func_8001CE70(TextGlyphResource *resource, ActorAnimation *animation,
                   int reference)
{
    unsigned char path[100];
    int result;

    if (animation->field08 >= 0) {
        func_8003B6E4(path, D_800906D0);
        func_8003B734(path, func_800383C4(animation->field08));
        if (func_8003B4C0(path, '.') != 0) {
            func_8003B6E4(func_8003B4C0(path, '.'), D_800906D8);
        } else {
            func_8003B734(path, D_800906E0);
        }
        result = func_8003CB10(resource->kind, animation->loopIndex,
                               path, animation->field08);
        animation->loopIndex = result;
        if ((short)result == -1) {
            func_8001C0D0((char *)D_800906E8, path);
        }
    } else if (animation->field08 != -2) {
        animation->loopIndex = reference;
    }
}
