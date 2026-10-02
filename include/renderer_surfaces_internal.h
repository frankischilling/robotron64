#ifndef ROBOTRON_RENDERER_SURFACES_INTERNAL_H
#define ROBOTRON_RENDERER_SURFACES_INTERNAL_H

#include "model_geometry_internal.h"
#include "renderer_setup_internal.h"
#include "renderer_texture_cache.h"
#include "object_runtime.h"

extern int D_800C8DFC;

/* Four input records each contain three signed coordinate words. */
void func_80042BDC(int *first, int *second, int *third, int *fourth);
void func_80043070(int x, int z);
void func_8004729C(int enabled);

#endif
