#include "../../include/model_geometry_internal.h"

void func_8003F314(ModelGeometryNode *nodes, int nodeIndex, FixedMatrix *parent,
                  int *position, void *forwarded)
{
    int translated[3];
    FixedMatrix rotation;
    FixedMatrix combined;
    ModelGeometryNode *node;
    RendererNormal *angles;
    short angleX;
    int child;

    node = &nodes[nodeIndex];
    angles = &D_800CD29C[nodeIndex];
    angleX = (*angles)[0];
    if (angleX == 0 && (*angles)[1] == 0 && (*angles)[2] == 0) {
        func_8004DB34(&rotation);
    } else {
        func_8003D2C0(angleX, (*angles)[1], (*angles)[2], &rotation);
    }
    func_8004D4B4(translated, parent, node->position);
    translated[0] += position[0];
    translated[1] += position[1];
    translated[2] += position[2];
    func_8004D884(&combined, parent, &rotation);
    /* This single-pass child group preserves IDO's pointer lifetimes. */
    do {
        for (child = 0; child < node->childCount; child++) {
            func_8003F314(nodes, node->children[child], &combined, translated, forwarded);
        }
    } while (0);
}
