#include "../../include/actor_resource_internal.h"
#include "../../include/game_memory.h"

extern unsigned char *func_800383C4(int identifier);
extern int func_80003A7C(int identifier, unsigned char *name);

int func_8001CF68(TextGlyphResource *resource, int loadGeometry)
{
    ActorResource58Internal *entry = (ActorResource58Internal *)resource;
    ActorAnimation *animation;
    int index;
    ActorAnimation *firstAnimation;
    unsigned char *extension;
    unsigned char path[100];
    int result;

    if (entry->word04.fields.flags06.bits.loaded) {
        return 2;
    }

    if (entry->word04.bits.defined == 0) {
        func_8001C0D0((char *)D_80090704);
    }

    if (func_800391C0(entry->kind) == -1) {
        func_8001C0D0((char *)D_80090734);
    }

    func_8003B6E4(path, D_8009074C);
    func_8003B734(path, func_800383C4(entry->modelName1E));
    extension = func_8003B4C0(path, '.');
    if (extension != 0) {
        *extension = 0;
    }

    if (loadGeometry != 0) {
        entry->modelHandle1C =
            func_8003C94C(entry->kind, entry->modelHandle1C, path, entry->modelName1E);
    } else {
        entry->modelHandle1C = -1;
    }

    if (entry->bitmapName26 != -1) {
        func_8003B6E4(path, D_80090754);
        func_8003B734(path, func_800383C4(entry->bitmapName26));
        extension = func_8003B4C0(path, '.');
        if (extension != 0) {
            func_8003B6E4(func_8003B4C0(path, '.'), D_80090760);
        } else {
            func_8003B734(path, D_80090768);
        }
        entry->bitmapHandle24 = func_8003CA34(entry->bitmapHandle24, path,
                                               entry->bitmapName26);
    }

    func_8003B6E4(path, D_80090770);
    func_8003B734(path, func_800383C4(entry->textureMapName22));
    extension = func_8003B4C0(path, '.');
    if (extension != 0) {
        func_8003B6E4(func_8003B4C0(path, '.'), D_8009077C);
    } else {
        func_8003B734(path, D_80090784);
    }

    if (loadGeometry != 0) {
        result = func_8003CA24(entry->kind, entry->textureMapHandle20, path);
        entry->textureMapHandle20 = result;
        if ((short)result == -1) {
            func_8001C0D0((char *)D_8009078C, path);
        } else {
            entry->textureMapHandle20 = -1;
        }
    }

    for (index = 0; index < 10; index++) {
        animation = entry->animations[index];
        if (animation != 0) {
            if (index == 0) {
                firstAnimation = animation;
            }
            func_8001CE70(resource, animation, firstAnimation->loopIndex);
            if (animation->frameIndex == -1) {
                animation->frameIndex = firstAnimation->frameIndex;
            }
            if (animation->field02 != -1) {
                animation->track =
                    func_80003A7C(animation->field02, func_800383C4(animation->field02));
            }
            animation->objectIndex = index;
            func_800391F0(entry->kind, animation, entry->modelHandle1C,
                          entry->textureMapHandle20, entry->bitmapHandle24);
        }
    }

    entry->word04.fields.flags06.bits.loaded = 1;
    return 1;
}
