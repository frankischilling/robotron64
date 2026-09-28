#include "../../include/rom_files.h"
#include "../../include/debug_output.h"

extern unsigned char D_80095B40[];

int func_8004ED14(int unused)
{
    double numerator = 10.0;
    double denominator = 0.0;

    func_8003CF88(D_80095B40);
    return numerator / denominator;
}
