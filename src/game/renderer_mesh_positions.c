#include "../../include/renderer_primitives_internal.h"

static const unsigned char D_800951A0[] = "TOO MANY VERTS %d MAX=%d %s %d\n";
static const unsigned char D_800951C0[] = "prims.c";

void func_80045934(RendererMeshPrefix *mesh, RendererPosition *positions)
{
    int base;
    /* Unused local slots retained from the target stack layout. */
    int unused0;
    int unused1;
    int used;
    int index;

    base = D_80123AE4;
    used = mesh->vertexCount + base - D_80123B20;

    if (used > 10000) {
        func_800496E0((unsigned char *)D_800951A0, used, 10000, D_800951C0, 0x42E);
    }
    for (index = 0; index < mesh->vertexCount; index++) {
        RendererVertex *vertex = &D_800CDBD0[base + index];
        RendererPosition *position = &positions[index];
        RENDERER_SET_POSITION(*vertex, *position);
    }
}
