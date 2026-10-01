#include "../../include/early_render_internal.h"

void func_8000B06C(int *first, int *second, int *third, int *fourth)
{
    int red;
    int green;
    int blue;
    red = D_80138270;
    green = D_80138274;
    blue = D_8013826C;
    D_800CDBD0[D_80123AE4 + 0].color.color[3] = 128;
    D_800CDBD0[D_80123AE4 + 1].color.color[3] = 128;
    D_800CDBD0[D_80123AE4 + 2].color.color[3] = 128;
    D_800CDBD0[D_80123AE4 + 3].color.color[3] = 128;
    D_800CDBD0[D_80123AE4 + 0].color.color[0] = red;
    D_800CDBD0[D_80123AE4 + 1].color.color[0] = red;
    D_800CDBD0[D_80123AE4 + 2].color.color[0] = red;
    D_800CDBD0[D_80123AE4 + 3].color.color[0] = red;
    D_800CDBD0[D_80123AE4 + 0].color.color[1] = green;
    D_800CDBD0[D_80123AE4 + 1].color.color[1] = green;
    D_800CDBD0[D_80123AE4 + 2].color.color[1] = green;
    D_800CDBD0[D_80123AE4 + 3].color.color[1] = green;
    D_800CDBD0[D_80123AE4 + 0].color.color[2] = blue;
    D_800CDBD0[D_80123AE4 + 1].color.color[2] = blue;
    D_800CDBD0[D_80123AE4 + 2].color.color[2] = blue;
    D_800CDBD0[D_80123AE4 + 3].color.color[2] = blue;
    D_800CDBD0[D_80123AE4 + 0].color.position[0] = first[0];
    D_800CDBD0[D_80123AE4 + 0].color.position[1] = first[1];
    D_800CDBD0[D_80123AE4 + 0].color.position[2] = first[2];
    D_800CDBD0[D_80123AE4 + 1].color.position[0] = second[0];
    D_800CDBD0[D_80123AE4 + 1].color.position[1] = second[1];
    D_800CDBD0[D_80123AE4 + 1].color.position[2] = second[2];
    D_800CDBD0[D_80123AE4 + 2].color.position[0] = third[0];
    D_800CDBD0[D_80123AE4 + 2].color.position[1] = third[1];
    D_800CDBD0[D_80123AE4 + 2].color.position[2] = third[2];
    D_800CDBD0[D_80123AE4 + 3].color.position[0] = fourth[0];
    D_800CDBD0[D_80123AE4 + 3].color.position[1] = fourth[1];
    D_800CDBD0[D_80123AE4 + 3].color.position[2] = fourth[2];
    FRAME_COMMAND(0x0400103F, &D_800CDBD0[D_80123AE4]);
    FRAME_COMMAND(0xB1020406, 0x00020600);
    FRAME_COMMAND(0xB1040200, 0x00040006);
    D_80123AE4 += 4;
}
