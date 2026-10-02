#include "../../../include/renderer_surfaces_internal.h"

/* Complete candidate; excluded until all compiled instructions match. */
typedef struct RendererSurfacePosition {
    int x;
    int y;
    int z;
} RendererSurfacePosition;

typedef char RendererSurfacePositionMustBe12Bytes[
    sizeof(RendererSurfacePosition) == 12 ? 1 : -1];

void func_80042BDC(int *firstInput, int *secondInput, int *thirdInput, int *fourthInput)
{
    RendererSurfacePosition first;
    RendererSurfacePosition second;
    RendererSurfacePosition third;
    RendererSurfacePosition fourth;
    RendererPosition transformedFirst;
    RendererPosition transformedSecond;
    RendererPosition transformedThird;
    RendererPosition transformedFourth;
    RendererVertex *vertices;
    int cameraX;
    int cameraY;
    int cameraZ;

    cameraX = D_800C8BD8.position[0];
    cameraY = D_800C8BD8.position[1];
    cameraZ = D_800C8BD8.position[2];
    first.x = firstInput[0];
    first.y = firstInput[1];
    first.z = firstInput[2];
    second.x = secondInput[0];
    second.y = secondInput[1];
    second.z = secondInput[2];
    third.x = thirdInput[0];
    third.y = thirdInput[1];
    third.z = thirdInput[2];
    fourth.x = fourthInput[0];
    fourth.y = fourthInput[1];
    fourth.z = fourthInput[2];

    first.x -= cameraX;
    first.y -= cameraY;
    first.z -= cameraZ;
    second.x -= cameraX;
    second.y -= cameraY;
    second.z -= cameraZ;
    third.x -= cameraX;
    third.y -= cameraY;
    third.z -= cameraZ;
    fourth.x -= cameraX;
    fourth.y -= cameraY;
    fourth.z -= cameraZ;
    first.x >>= 1;
    first.y >>= 1;
    first.z >>= 1;
    second.x >>= 1;
    second.y >>= 1;
    second.z >>= 1;
    third.x >>= 1;
    third.y >>= 1;
    third.z >>= 1;
    fourth.x >>= 1;
    fourth.y >>= 1;
    fourth.z >>= 1;
    func_8004D4B4(transformedFirst, &D_800CD250, (int *)&first);
    func_8004D4B4(transformedSecond, &D_800CD250, (int *)&second);
    func_8004D4B4(transformedThird, &D_800CD250, (int *)&third);
    func_8004D4B4(transformedFourth, &D_800CD250, (int *)&fourth);
    vertices = &D_800CDBD0[D_80123AE4];
    vertices[0].color.texture[0] = 0;
    vertices[0].color.texture[1] = 0;
    vertices[1].color.texture[0] = 1984;
    vertices[1].color.texture[1] = 0;
    vertices[2].color.texture[0] = 1984;
    vertices[2].color.texture[1] = 1984;
    vertices[3].color.texture[1] = 1984;
    vertices[3].color.texture[0] = 0;
    func_80045214(transformedFirst, transformedSecond, transformedThird, transformedFourth);
}
