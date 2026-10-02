#include "../../../include/renderer_primitives_internal.h"
#include "../../../include/renderer_draw_state_internal.h"
#include "../../../include/renderer_texture_cache.h"
#include "../../../include/early_render_effects_internal.h"
#include "../../../include/scalar_math.h"

extern int D_800C8DFC;
#include "../../../include/renderer_setup_internal.h"
extern FixedMatrix D_800CD250;
void func_8004D4B4(int *output, FixedMatrix *matrix, int *input);
void func_8004729C(int enabled);

/* Excluded candidate; see docs/renderer-grid-and-setup.md. */
void func_800431C0(int unused)
{
    int extent = 3;
    int rows;
    int vertex;
    int row;
    int column;
    int shade;
    int camera[3];
    int transformed[3];
    RendererDrawState draw;
    RendererVertex *vertices;

    FRAME_COMMAND(0xE7000000, 0);
    func_8004729C(1);
    FRAME_COMMAND(0xFCFFFFFF, 0xFFFCF87C);
    FRAME_COMMAND(0xB900031D, 0x004049D8);
    FRAME_COMMAND(0xBA001001, 0);
    FRAME_COMMAND(0xBA000C02, 0x2000);
    FRAME_COMMAND(0xBA001301, 0x80000);
    FRAME_COMMAND(0xBA000E02, 0);
    FRAME_COMMAND(0xBB000001, 0x80008000);
    func_80042830(D_800C8DFC);
    camera[0] = -D_800C8BD8.position[0] >> 1;
    camera[1] = -D_800C8BD8.position[1] >> 1;
    camera[2] = -D_800C8BD8.position[2] >> 1;
    func_8004D4B4(transformed, &D_800CD250, camera);
    draw.projectedPosition[0] = transformed[0];
    draw.projectedPosition[1] = transformed[1];
    draw.projectedPosition[2] = transformed[2];
    func_80047D88(&draw, &D_800CD250);
    D_80123AE4 = func_80047048();
    if (D_80123AE4 != -1) {
        rows = extent * 2 + 1;
        vertex = 0;
        shade = 0;
        vertices = &D_800CDBD0[D_80123AE4];
        for (row = -extent; row < extent + 1; row++) {
            for (column = -extent; column < extent + 1; column++) {
                func_8004CEF0(column * 1383);
                vertices[vertex].color.color[0] = (shade * 128) >> 8;
                vertices[vertex].color.color[1] = ((256 - shade) * 128) >> 8;
                vertices[vertex].color.position[0] = column * 1383;
                vertices[vertex].color.position[1] = 0;
                vertices[vertex].color.position[2] = row * 1383;
                D_800CDBD0[D_80123AE4 + vertex].color.color[0] = 64;
                D_800CDBD0[D_80123AE4 + vertex].color.color[1] = 64;
                D_800CDBD0[D_80123AE4 + vertex].color.color[2] = 64;
                D_800CDBD0[D_80123AE4 + vertex].color.color[3] = 255;
                D_800CDBD0[D_80123AE4 + vertex].color.texture[0] = (column * 32) << 6;
                D_800CDBD0[D_80123AE4 + vertex].color.texture[1] = row << 11;
                vertex++;
                shade = (shade + 64) & 255;
            }
        }
        func_80047094(vertex);
        for (row = 0; row != rows; row++) {
            for (column = 0; column < rows - 1; column++) {
                FRAME_COMMAND(0x0400081F, &D_800CDBD0[D_80123AE4 + column]);
                FRAME_COMMAND(0x0404081F, &D_800CDBD0[D_80123AE4 + column + row * rows]);
                RENDERER_QUAD(0, 1, 3, 2);
                RENDERER_QUAD(0, 2, 3, 1);
            }
        }
        FRAME_COMMAND(0xE7000000, 0);
        FRAME_COMMAND(0xFCFFFFFF, 0xFFFE793C);
        FRAME_COMMAND(0xBA001301, 0);
        FRAME_COMMAND(0x06000000, D_8007CA70);
        func_80046AD0();
    }
}
