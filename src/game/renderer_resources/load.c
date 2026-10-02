#include "../../../include/destination_format.h"
#include "../../../include/renderer_resource_loader.h"
#include "../../../include/renderer_primitives_internal.h"
#include "../../../include/resource_strings.h"
#include "../../../include/rom_files.h"
#include "../../../include/heap.h"
#include "../../../include/debug_output.h"

extern void *func_8004BBD0(unsigned int size);
extern void func_8003F7F4(RendererMeshPrefix *mesh);

/* Excluded candidate; see docs/resource-cache-and-formatting.md. */
void func_8004BD00(int model, int animation, int bitmap)
{
    void *data;
    unsigned char *extension;
    unsigned char filename[256];
    unsigned char *name;
    unsigned char *entry;
    int offset;
    unsigned int size;
    int index;
    ObjectRecoveryDatPoint *point;

    D_8007BB14 = 1;
    if (model != -1) {
        offset = model * 20;
        entry = D_80078274 + offset;
        if (((RendererModelCacheView *)entry)->loaded == 0) {
            name = func_800383C4(((RendererModelCacheView *)entry)->identifier);
            extension = func_8003B4C0(name, '.');
            if (extension != 0) {
                *extension = 0;
            }
            func_800363D0(filename, (unsigned char *)D_80095530, name);
            if (D_8007BB14 == 0) {
                func_800496E0((unsigned char *)D_80095540, filename, model, D_80095564, 0x92);
            }
            size = func_8004EF6C(filename);
            size = (size + 3) & ~3;
            D_8008D360 += size;
            data = func_8004BBD0(size);
            func_8004EE9C(filename, data);
            func_8003C6B8(data);
            func_8003F7F4(data);
            ((RendererModelCacheView *)entry)->loaded = 1;
            ((RendererModelCacheView *)entry)->data = data;
        }
    }
    if (animation >= 0 && animation < 255) {
        offset = animation * 16;
        entry = D_80078274 + offset;
        if (((RendererAnimationCacheView *)entry)->loaded == 0) {
            name = func_800383C4(((RendererAnimationCacheView *)entry)->identifier);
            extension = func_8003B4C0(name, '.');
            if (extension != 0) {
                *extension = 0;
            }
            func_800363D0(filename, (unsigned char *)D_80095570, name);
            if (D_8007BB14 == 0) {
                func_800496E0((unsigned char *)D_8009557C, filename, animation, D_8009559C, 0xAA);
            }
            size = func_8004EF6C(filename);
            size = (size + 3) & ~3;
            D_8008D368 += size;
            data = func_8004BBD0(size);
            func_8004EE9C(filename, data);
            ((RendererAnimationCacheView *)entry)->pointCount = ((RendererAnimationFilePrefix *)data)->pointCount;
            ((RendererAnimationCacheView *)entry)->frameCount = ((RendererAnimationFilePrefix *)data)->frameCount;
            point = (ObjectRecoveryDatPoint *)((unsigned char *)data + 8);
            ((RendererAnimationCacheView *)entry)->data = point;
            ((RendererAnimationCacheView *)entry)->loaded = 1;
            for (index = 0; index < ((RendererAnimationFilePrefix *)data)->pointCount *
                                      ((RendererAnimationFilePrefix *)data)->frameCount; index++) {
                point->x <<= 3;
                point->y <<= 3;
                point->z <<= 3;
                point++;
            }
        }
    }
    if (bitmap >= 0) {
        offset = bitmap * 8;
        entry = D_80078274 + offset;
        if (((RendererBitmapCacheView *)entry)->loaded == 0) {
            name = func_800383C4(((RendererBitmapCacheView *)entry)->identifier);
            extension = func_8003B4C0(name, '.');
            if (extension != 0) {
                *extension = 0;
            }
            func_800363D0(filename, (unsigned char *)D_800955A8, name);
            if (D_8007BB14 == 0) {
                func_800496E0((unsigned char *)D_800955B8, filename, bitmap, D_800955D8, 0xCC);
            }
            size = func_8004EF6C(filename);
            size = (size + 3) & ~3;
            D_8008D364 += size;
            data = (void *)(((unsigned int)func_8004DD6C(size + 8) + 7) & ~7);
            func_8004EE9C(filename, data);
            ((RendererBitmapCacheView *)entry)->loaded = 1;
            ((RendererBitmapCacheView *)entry)->data = data;
        }
    }
}
