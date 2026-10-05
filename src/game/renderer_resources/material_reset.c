#include "../../../include/renderer_material_internal.h"

void func_800420B0(void)
{
    int i;
    D_800BF2C0 = 0;
    D_800BEF60 = 0;
    func_8004BC8C();
    D_80126B74 = D_80126B78;
    D_80126B80 = 0;
    for (i = 0; i < 400; i++)
    {
        ((RendererMaterialSlotView *)(D_80078274 + i * 20))->flags = 128;
    }
    ((RendererMaterialSlotView *)(D_80078274 + D_800B1BE8[33].kind * 20))->flags = 0x4000;
    ((RendererMaterialSlotView *)(D_80078274 + D_800B1BE8[10].kind * 20))->flags = 0x4000;
    ((RendererMaterialSlotView *)(D_80078274 + D_800B1BE8[11].kind * 20))->flags = 0x4000;
    ((RendererMaterialSlotView *)(D_80078274 + D_800B1BE8[12].kind * 20))->flags = 0x4000;
    ((RendererMaterialSlotView *)(D_80078274 + D_800B1BE8[13].kind * 20))->flags = 0x4000;
    ((RendererMaterialSlotView *)(D_80078274 + D_800B1BE8[14].kind * 20))->flags = 0x4000;
    ((RendererMaterialSlotView *)(D_80078274 + D_8009F560[0].kind * 20))->flags = 0x2000;
    ((RendererMaterialSlotView *)(D_80078274 + D_8009F560[1].kind * 20))->flags = 0x2000;
    ((RendererMaterialSlotView *)(D_80078274 + D_8009F560[2].kind * 20))->flags = 0x2000;
    ((RendererMaterialSlotView *)(D_80078274 + D_8009F560[3].kind * 20))->flags = 0x2000;
    ((RendererMaterialSlotView *)(D_80078274 + D_8009F560[4].kind * 20))->flags = 0x2000;
    ((RendererMaterialSlotView *)(D_80078274 + D_8009F560[5].kind * 20))->flags = 0x2000;
    ((RendererMaterialSlotView *)(D_80078274 + D_8009F560[6].kind * 20))->flags = 0x2000;
    ((RendererMaterialSlotView *)(D_80078274 + D_8009F560[7].kind * 20))->flags = 0x2000;
    ((RendererMaterialSlotView *)(D_80078274 + D_8009F560[9].kind * 20))->flags = 0x4000;
    ((RendererMaterialSlotView *)(D_80078274 + D_8009F560[11].kind * 20))->flags = 0x800;
    ((RendererMaterialSlotView *)(D_80078274 + D_8009F560[12].kind * 20))->flags = 0x44;
    ((RendererMaterialSlotView *)(D_80078274 + D_8009F560[13].kind * 20))->flags = 0x2000;
    ((RendererMaterialSlotView *)(D_80078274 + D_8009F560[14].kind * 20))->flags = 0x2000;
    ((RendererMaterialSlotView *)(D_80078274 + D_8009F560[15].kind * 20))->flags = 0x2000;
    ((RendererMaterialSlotView *)(D_80078274 + ((TextGlyphResource *)&D_800AF1F0[2])->kind * 20))->flags = 0x44;
    ((RendererMaterialSlotView *)(D_80078274 + ((TextGlyphResource *)&D_800AF1F0[3])->kind * 20))->flags = 0x4000;
    ((RendererMaterialSlotView *)(D_80078274 + ((TextGlyphResource *)&D_800AF1F0[4])->kind * 20))->flags = 0x4000;
    ((RendererMaterialSlotView *)(D_80078274 + D_800B1BE8[5].kind * 20))->flags = 0x44;
    ((RendererMaterialSlotView *)(D_80078274 + D_800B1BE8[9].kind * 20))->flags = 0x800;
    ((RendererMaterialSlotView *)(D_80078274 + D_800B1BE8[18].kind * 20))->flags = 0x840;
    ((RendererMaterialSlotView *)(D_80078274 + D_800B1BE8[31].kind * 20))->flags = 0x42;
    ((RendererMaterialSlotView *)(D_80078274 + D_800B1BE8[36].kind * 20))->flags = 0x4040;
    ((RendererMaterialSlotView *)(D_80078274 + D_800B1BE8[131].kind * 20))->flags = 0x2000;
    ((RendererMaterialSlotView *)(D_80078274 + D_800B1BE8[28].kind * 20))->flags = 0x40;
    ((RendererMaterialSlotView *)(D_80078274 + D_800B1BE8[132].kind * 20))->flags = 0x800;
    ((RendererMaterialSlotView *)(D_80078274 + D_800B1BE8[137].kind * 20))->flags = 0x4040;
    ((RendererMaterialSlotView *)(D_80078274 + D_800B1BE8[134].kind * 20))->flags = 0x800;
    ((RendererMaterialSlotView *)(D_80078274 + D_800B1BE8[32].kind * 20))->flags = 0x4040;
    ((RendererMaterialSlotView *)(D_80078274 + D_800B1BE8[193].kind * 20))->flags = 0x800;
    ((RendererMaterialSlotView *)(D_80078274 + D_800B1BE8[194].kind * 20))->flags = 0x840;
    ((RendererMaterialSlotView *)(D_80078274 + D_800B1BE8[198].kind * 20))->flags = 0x840;
    ((RendererMaterialSlotView *)(D_80078274 + D_800B1BE8[199].kind * 20))->flags = 0x840;
    ((RendererMaterialSlotView *)(D_80078274 + D_800B1BE8[200].kind * 20))->flags = 0x840;
    ((RendererMaterialSlotView *)(D_80078274 + D_800B1BE8[201].kind * 20))->flags = 0x840;
    ((RendererMaterialSlotView *)(D_80078274 + D_800B1BE8[226].kind * 20))->flags = 0x44;
    ((RendererMaterialSlotView *)(D_80078274 + D_800B1BE8[227].kind * 20))->flags = 0x42;
    ((RendererMaterialSlotView *)(D_80078274 + D_800B1BE8[228].kind * 20))->flags = 0x4000;
    ((RendererMaterialSlotView *)(D_80078274 + D_800B1BE8[229].kind * 20))->flags = 0x42;
    ((RendererMaterialSlotView *)(D_80078274 + D_800B1BE8[211].kind * 20))->flags = 0x42;
    ((RendererMaterialSlotView *)(D_80078274 + D_800B1BE8[210].kind * 20))->flags = 0x2000;
    ((RendererMaterialSlotView *)(D_80078274 + D_800B1BE8[230].kind * 20))->flags = 0x4000;
    ((RendererMaterialSlotView *)(D_80078274 + D_800B1BE8[231].kind * 20))->flags = 0x4000;
    ((RendererMaterialSlotView *)(D_80078274 + D_800B1BE8[232].kind * 20))->flags = 0x4000;
    ((RendererMaterialSlotView *)(D_80078274 + D_800B1BE8[233].kind * 20))->flags = 0x4000;
    ((RendererMaterialSlotView *)(D_80078274 + D_800B1BE8[234].kind * 20))->flags = 0x4000;
    ((RendererMaterialSlotView *)(D_80078274 + D_800B1BE8[235].kind * 20))->flags = 0x4000;
    ((RendererMaterialSlotView *)&D_80078274[D_800B1BE8[22].kind * 20])->flags |= 0x1000;
    ((RendererMaterialSlotView *)&D_80078274[D_800B1BE8[181].kind * 20])->flags |= 0x1000;
    ((RendererMaterialSlotView *)&D_80078274[D_800B1BE8[182].kind * 20])->flags |= 0x1000;
    ((RendererMaterialSlotView *)&D_80078274[D_800B1BE8[183].kind * 20])->flags |= 0x1000;
    ((RendererMaterialSlotView *)&D_80078274[D_800B1BE8[184].kind * 20])->flags |= 0x1000;
    ((RendererMaterialSlotView *)(D_80078274 + ((TextGlyphResource *)&D_800AC998[0])->kind * 20))->flags = 0x2000;
    ((RendererMaterialSlotView *)(D_80078274 + ((TextGlyphResource *)&D_800AC998[3])->kind * 20))->flags = 0x2000;
    ((RendererMaterialSlotView *)(D_80078274 + D_8009AFD8[0].kind * 20))->flags = 0x2000;
    ((RendererMaterialSlotView *)(D_80078274 + D_8009AFD8[1].kind * 20))->flags = 0x2000;
    ((RendererMaterialSlotView *)(D_80078274 + D_8009AFD8[2].kind * 20))->flags = 0x2000;
    ((RendererMaterialSlotView *)(D_80078274 + D_8009AFD8[3].kind * 20))->flags = 0x2000;
    ((RendererMaterialSlotView *)&D_80078274[D_800ACE58[5].kind * 20])->flags |= 0x10;
    ((RendererMaterialSlotView *)&D_80078274[D_800ACE58[4].kind * 20])->flags |= 0x10;
    ((RendererMaterialSlotView *)&D_80078274[D_800ACE58[6].kind * 20])->flags |= 0x10;
    ((RendererMaterialSlotView *)&D_80078274[D_800ACE58[7].kind * 20])->flags |= 0x10;
    ((RendererMaterialSlotView *)(D_80078274 + D_800B1BE8[150].kind * 20))->flags = 0x800;
}
