#include "../../include/geometry_bridge_internal.h"

void func_8003D20C(int *position, int *angles)
{
    FixedMatrix first;
    FixedMatrix second;
    int result[3];

    func_8004DB34(&first);
    func_8004CF40(&second, &first, angles[0] & 0xFFD);
    func_8004D0DC(&first, &second, angles[1] & 0xFFD);
    func_8004D154(&second, &first, angles[2] & 0xFFD);
    func_8004D4B4(result, &second, position);
    position[0] = result[0];
    position[1] = result[1];
    position[2] = result[2];
}
