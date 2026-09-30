#include "../../include/game_memory.h"
#include "../../include/fixed_math.h"
#include "../../include/object_draw.h"
#include "../../include/object_runtime.h"

typedef struct ObjectRuntimeSelection {
    unsigned char unknown00[0x0C];
    short objectIndex0C;
} ObjectRuntimeSelection;

typedef struct ObjectRuntimeRenderInfo {
    unsigned char unknown00[0x18];
    unsigned int flags18;
} ObjectRuntimeRenderInfo;

extern ObjectRuntimeSelection *D_800BEF60;
extern ObjectRecord *D_800BF2C0;
extern int D_800BF2C4;
extern int D_800BF5E8;
extern int D_800BF6F8;
extern int D_800BF900;
extern int D_800BF904;
extern int D_800BF908;
extern int D_800BF90C;
extern int D_800BF910;

extern unsigned char D_800781F4[];
extern int D_800781F0;
extern int D_8007BAC4[][2];
extern int D_8007CDC0;
extern int D_8007D5D8;
extern unsigned int D_8009EF94;
extern int D_8009EFA0;
extern int D_800BEF6C;
extern int D_800C85B8;
extern int D_800C86C4[];
extern int D_80123ADC;
extern int D_80123AE8;
extern FixedMatrix D_800CD250;
extern unsigned char D_800CD278[];

extern void func_8000A200(unsigned char, unsigned char, unsigned char);
extern void func_8000A388(int, int, int, int, int);
extern void func_8000AC6C(int, int, int, int);
extern void func_8000CD50(ObjectRecord *, ObjectRecord *, int, int, int, int);
extern int func_80039CD0(int);
extern int func_80039E3C(int);
extern void func_8003F480(void);
extern void func_8004729C(int);
extern void func_800474F8(short, short, short);
extern void func_8004BD00(int, int, int);
extern void func_8004E968(ObjectDrawResource *, int, int);

void func_8003A8B0(void)
{
    int *activity;
    ObjectDrawCallback baseCallback;
    ObjectDrawCallback callback;
    ObjectDrawResource *resource;
    ObjectModel *model;
    ObjectRecord *object;
    ObjectRuntimeRenderInfo *renderInfo;
    ObjectResourceType *resourceType;
    unsigned char *palette;
    unsigned int flags;
    int objectIndex;
    int limit;
    int scaled;
    int result;

    if (D_800BEF60 != 0) {
        D_800BF2C0 = &D_800BF918[D_800BEF60->objectIndex0C];
    }

    func_8003F480();
    func_8003B520(D_800CD278, &D_800CD250, 0x24);
    func_8003A8A8();
    func_8003B254();

    D_800781F0 = 0;
    activity = D_800C86C4;
    objectIndex = 1;

    do {
        if (*activity == 0 && func_80039E3C(objectIndex) != 0) {
            D_800BF2C4++;
            D_800BF90C = -1;
            object = &D_800BF918[objectIndex];
            resource = object->drawResource;
            callback = 0;
            if ((unsigned int)resource >= 2U) {
                callback = resource->draw;
            }

            D_800BF6F8 = object->index02;
            if (callback == 0) {
                model = object->model;
                renderInfo = (ObjectRuntimeRenderInfo *)(D_80078274 + model->modelIndex * 0x14);
                D_800BF910 = renderInfo->flags18 & 0x1000;
                callback = func_8003A540;
                baseCallback = func_8003A540;

                switch (object->unknown14[1]) {
                case 0x6C:
                    D_800BF6F8 = 1;
                    object->angle[2] += 0x180;
                    func_8000CD50(&D_800BF918[object->value0A], object,
                                  0x190, 0x384, 0xC8, 1);
                    break;
                case 0x6D:
                    D_800BF6F8 = 1;
                    func_8000CD50(&D_800BF918[object->value0A], object,
                                  0, 0x3E8, 0x14, 0);
                    object->angle[2] = 0x400;
                    object->angle[1] += 0x180;
                    break;
                case 0x6E:
                    D_800BF6F8 = 1;
                    func_8000CD50(&D_800BF918[object->value0A], object,
                                  0x190, 0x1F4, 0, 2);
                    break;
                }

                D_800C85B8 = 0;
                if (D_800C85B8 == 0 && (renderInfo->flags18 & 0x80) != 0) {
                    callback = func_8003A5D8;
                }

                if (object->property12 != 0 && func_80039E3C(objectIndex) != 0) {
                    func_8000AC6C(object->position[0], object->position[1],
                                  object->position[2], object == D_800BF2C0 ? 0 : 1);
                }

                flags = renderInfo->flags18;
                D_800C85B8 = 0;
                if ((flags & 0x40) != 0) {
                    D_800C85B8 = 1;
                }
                if ((flags & 0x4) != 0) {
                    func_8004729C(6);
                    flags = renderInfo->flags18;
                }
                if ((flags & 0x2) != 0) {
                    func_8004729C(4);
                    flags = renderInfo->flags18;
                }
                if ((flags & 0x2000) != 0) {
                    func_8004729C(2);
                    flags = renderInfo->flags18;
                }
                if ((flags & 0x4000) != 0) {
                    func_8004729C(1);
                    flags = renderInfo->flags18;
                }
                if ((flags & 0x10) != 0) {
                    D_8007CDC0 = object->index02;
                    limit = func_80039CD0(objectIndex);
                    func_8004E968(resource, D_8007CDC0, limit);
                    func_8004729C(4);
                    flags = renderInfo->flags18;
                }
                if ((flags & 0x80) != 0) {
                    func_8004729C(4);
                    D_800C85B8 = 1;
                    flags = renderInfo->flags18;
                }
                if ((flags & 0x4) != 0) {
                    func_8004729C(6);
                    D_800C85B8 = 1;
                }

                D_8007CDC0 = 0;
                if ((unsigned int)resource >= 2U && resource->mode1F == 1) {
                    resourceType = resource->type;
                    if (resourceType->kind == 0 && resourceType->variant >= 0x19 &&
                        resourceType->variant < 0x1B) {
                        callback = baseCallback;
                        D_8007CDC0 = object->index02;
                        limit = func_80039CD0(objectIndex);
                        func_8004729C(1);
                        D_80123AE8 = ((limit - D_8007CDC0) * 0xFF) / limit;
                        scaled = D_8007CDC0 * 2;
                        D_8007CDC0 = scaled;
                        if (limit < scaled) {
                            D_8007CDC0 = limit;
                            scaled = limit;
                        }
                        D_8007CDC0 = (scaled << 8) / limit;
                        D_800BF90C = 0;
                        D_800BF6F8 = 1;
                        D_800C85B8 = 0;
                    }
                }

                if (object->unknown14[1] == 0x67) {
                    callback = baseCallback;
                    D_8007CDC0 = object->index02;
                    limit = func_80039CD0(objectIndex);
                    func_8004729C(1);
                    D_80123AE8 = ((limit - D_8007CDC0) * 0xFF) / limit;
                    scaled = D_8007CDC0 * 2;
                    D_8007CDC0 = scaled;
                    if (limit < scaled) {
                        D_8007CDC0 = limit;
                        scaled = limit;
                    }
                    D_8007CDC0 = (scaled << 8) / limit;
                    D_800BF90C = 0;
                    D_800BF6F8 = 1;
                    D_800C85B8 = 0;
                }

                if (object->unknown14[1] == 0x6B) {
                    if ((unsigned int)resource >= 2U) {
                        resourceType = resource->type;
                        if (resourceType->kind == 0 && resourceType->variant >= 0x19 &&
                            resourceType->variant < 0x1D) {
                            D_800BF6F8 = 1;
                            func_8004729C(0x12);
                            goto normal_render_flags;
                        }
                    }
                    func_8004729C(2);
                    resourceType = resource->type;
                    palette = D_800781F4 + resourceType->variant * 3;
                    func_8000A200(palette[0], palette[1], palette[2]);
                    func_8000A388(object->position[0], object->position[1],
                                  object->position[2],
                                  D_8009EFA0 - resource->timestamp48, 0x12C);
                    goto next_object;
                }

normal_render_flags:
                if ((renderInfo->flags18 & 0x800) != 0) {
                    D_8007D5D8 = -1;
                    if (D_800C85B8 != 0) {
                        func_8004729C(0xE);
                    } else {
                        func_8004729C(0x10);
                    }
                    callback = func_8003A58C;
                }
                if (object->unknown0C[4] != 0) {
                    func_8004729C(0x18);
                    callback = func_8003A778;
                }
                D_80123ADC = -1;
            }

            model = object->model;
            D_800BF900 = model->modelIndex;
            D_800BF904 = model->frames[object->unknown0C[0]]->frame;
            D_800BF908 = model->drawMode;
            D_800BF5E8 = D_8007BAC4[D_800BF908][0];
            func_8004BD00(D_800BF900, D_800BF904, D_800BF908);

            if (func_80039E3C(objectIndex) != 0) {
                if ((unsigned int)resource >= 2U && resource->mode1F == 1) {
                    result = 1;
                } else {
                    func_800474F8(object->value04[0], object->value04[1], object->value04[2]);
                }

                if (object->unknown14[0] == 0) {
                    if (object == D_800BF2C0 && D_800BEF6C != -1) {
                        func_8003B2B0(D_800BF904, D_800BF6F8);
                        D_800BF904 = 0xFE;
                        D_800BF6F8 = 0;
                    }
                    if (callback != 0) {
                        result = callback((unsigned int)resource, object);
                    }
                    if (result != 0) {
                        D_800781F0 += object->value16;
                    }
                } else {
                    if (D_800BF904 != 0xFF && D_800BF904 != -1) {
                        func_800394C0(objectIndex, 0.0f);
                        func_8003956C(objectIndex, 0.0f);
                        func_800395C0(objectIndex, 0.0f);
                    }
                    if (callback != 0) {
                        result = callback((unsigned int)resource, object);
                    }
                }
            }

            object->value04[0] -= D_8009EF94 >> 2;
            if (object->value04[0] < 0) {
                object->value04[0] = 0;
            }
            object->value04[1] -= D_8009EF94 >> 2;
            if (object->value04[1] < 0) {
                object->value04[1] = 0;
            }
            object->value04[2] -= D_8009EF94 >> 2;
            if (object->value04[2] < 0) {
                object->value04[2] = 0;
            }
        }

next_object:
        objectIndex++;
        activity++;
    } while (objectIndex != 0x12C);
}
