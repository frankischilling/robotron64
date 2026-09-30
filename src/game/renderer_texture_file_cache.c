#include "../../include/renderer_texture_cache.h"
#include "../../include/controller_input.h"
#include "../../include/rom_files.h"
#include "../../include/renderer_geometry_internal.h"

int D_8007CD8C = -1;
int D_8007CD90 = 0;
RendererTextureCacheImage D_800CD3C0;
int D_800CDBC0;

void func_80042830(int unused)
{
    if (D_8013DBF8[0] & 0x2000) {
        D_8007CD90++;
    }
    if (D_8007CD8C != D_800CDBC0) {
        func_8004EE9C(D_8007CCC0[D_800CDBC0], D_800CD3C0);
        D_8007CD8C = D_800CDBC0;
    }
    func_800463E8((unsigned int)D_800CD3C0);
}
