#include "../../include/game_memory.h"
#include "../../include/platform_services.h"
extern int D_800AD284;
extern int D_8009EFA4;
extern int D_8009EFAC;
extern int D_8009EFA0;
extern unsigned int D_8009EF94;
extern unsigned int D_8009EF98;
extern unsigned int D_8009EF9C;
extern int D_800BF2B0;
extern unsigned int D_800BF120[];
extern int D_800781D0;
extern float D_FLT_800C8DF4;
extern float D_FLT_800C8DF8;
void func_80031ECC(void);

void func_80038598(void)
{
    int count;
    int index;
    int weight;
    int totalWeight;
    unsigned int elapsed;

    func_80031ECC();
    if (D_800AD284 < 0 || D_800AD284 > 10) {
        D_800AD284 = 0;
    }
    D_8009EFA4 = func_8003BFA4();
    D_8009EF94 = 0;
    D_800BF2B0 = (D_8009EFA4 - D_8009EFAC) * 75 / 100;
    func_8003B520(D_800BF120, &D_800BF120[1], 0);
    D_800BF120[0] = D_800BF2B0;
    count = D_800781D0 + 1;
    if (count <= 0) {
        D_800781D0 = count;
    } else {
        D_800781D0 = 1;
    }
    totalWeight = 0;
    weight = 1;
    for (index = 0; index < D_800781D0; index++) {
        D_8009EF94 += weight * D_800BF120[index];
        totalWeight += weight;
        weight--;
    }
    elapsed = D_8009EF94 = D_8009EF94 / totalWeight;
    D_FLT_800C8DF4 = 1000.0 / elapsed;
    D_FLT_800C8DF8 = 30.0 / D_FLT_800C8DF4;
    D_8009EF9C = elapsed;
    if (elapsed > 100) {
        elapsed = D_8009EF94 = 100;
    }
    D_8009EFAC = D_8009EFA4;
    D_8009EF98 = elapsed;
    if (D_800AD284 == 0) {
        D_8009EFA0 += elapsed;
    } else {
        D_8009EF94 = 0;
    }
}
