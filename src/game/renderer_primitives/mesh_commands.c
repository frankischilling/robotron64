#include "../../../include/renderer_primitives_internal.h"

/* Excluded candidate; see docs/renderer-mesh-resources.md. */
int func_80045A08(short *commands, RendererMeshPrefix *mesh, int destination)
{
    short first;
    short count;
    short second;
    short third;
    short fourth;
    short colorIndex;
    int remaining;
    int commandDestination;
    RendererVertex *vertices;
    unsigned char *color;
    int copyDestination;
    int loadDestination;

    copyDestination = destination;
    loadDestination = destination;
    for (;;) {
        switch (*commands++) {
        case 0x7001:
            first = commands[0];
            count = commands[1];
            commands += 2;
            if (D_800C85B8 != 0) {
                func_800460D8(first, count, copyDestination, mesh->normals);
            } else {
                func_80045F40(first, count, copyDestination);
            }
            copyDestination += count;
            break;
        case 0x7002:
            count = *commands++;
            if (count <= 32) {
                FRAME_COMMAND(0x04000000 | (((count << 10) |
                              (sizeof(RendererVertex) * count - 1)) & 0xFFFF),
                              &D_800CDBD0[loadDestination]);
            } else {
                remaining = count;
                vertices = &D_800CDBD0[loadDestination];
                commandDestination = 0;
                while (remaining > 0) {
                    if (remaining > 32) {
                        FRAME_COMMAND((GRAPHICS_FIELD(commandDestination, 16, 8) | 0x04000000) | ((32 << 10) | (sizeof(RendererVertex) * 32 - 1)), vertices);
                    } else {
                        FRAME_COMMAND((GRAPHICS_FIELD(commandDestination, 16, 8) | 0x04000000) |
                                      (((remaining << 10) | (sizeof(RendererVertex) * remaining - 1)) & 0xFFFF), vertices);
                    }
                    remaining -= 32;
                    commandDestination += 64;
                    vertices += 32;
                }
            }
            loadDestination += count;
            break;
        case 0x7003:
            D_80123B10++, D_80123B18++;
            first = commands[0];
            second = commands[1];
            third = commands[2];
            commands += 3;
            RENDERER_TRIANGLE(first, second, third);
            break;
        case 0x7004:
            D_80123B14++, D_80123B18++;
            first = commands[0];
            second = commands[1];
            third = commands[2];
            fourth = commands[3];
            commands += 4;
            RENDERER_QUAD(first, second, third, fourth);
            break;
        case 0x7010:
            colorIndex = *commands++ & 0xFF;
            if (D_800C85B8 != 0) {
                if (colorIndex != D_80123ADC) {
                    D_80123ADC = colorIndex;
                    if (colorIndex == 1 || colorIndex == 186) {
                        FRAME_COMMAND(0x03860010, &D_80123B28[colorIndex]);
                    } else {
                        color = (unsigned char *)&D_8007BF34[colorIndex];
                        D_80123AF0 = color[0];
                        D_80123AF4 = color[1];
                        D_80123AF8 = color[2];
                        FRAME_COMMAND(0xBC00000A, *(unsigned int *)color);
                        FRAME_COMMAND(0xBC00040A, *(unsigned int *)color);
                        D_80123AF0 >>= 1;
                        D_80123AF4 >>= 1;
                        D_80123AF8 >>= 1;
                        FRAME_COMMAND(0xBC00200A, (D_80123AF0 << 24) | (D_80123AF4 << 16) | (D_80123AF8 << 8));
                        FRAME_COMMAND(0xBC00240A, (D_80123AF0 << 24) | (D_80123AF4 << 16) | (D_80123AF8 << 8));
                    }
                }
            } else {
                color = (unsigned char *)&D_8007BF34[colorIndex];
                D_80123AF0 = color[0];
                D_80123AF4 = color[1];
                D_80123AF8 = color[2];
            }
            break;
        case 0x7000:
            return loadDestination;
        }
    }
}
