#include "../../../include/renderer_diagnostic_internal.h"

/* Matching report; see docs/startup-projection-and-diagnostics.md. */
void func_8004C6E0(void)
{
    int availableBytes;
    unsigned int regionEnd;
    int heapBytes;

    if (D_8007D8F0 >= 10) {
        func_80048DC0((char *)D_80095640);
        func_80048DC0((char *)D_8009568C, D_8007D6B0, D_80095694);
        func_80048DC0((char *)D_800956A0, D_8007D8F0);
        func_80048DC0((char *)D_800956AC, D_80138250);
        func_80048DC0((char *)D_800956BC, D_800C8DFC);
        func_80048DC0((char *)D_800956C8, D_80000450, D_800518E0, D_800518E0 - D_80000450);
        func_80048DC0((char *)D_800956F0, D_80072B30, D_8008D780, D_8008D780 - D_80072B30);
        regionEnd = (unsigned int)D_80190170;
        func_80048DC0((char *)D_80095718, D_80097290, D_80190170, (unsigned int)D_80190170 - (unsigned int)D_80097290);
        func_80048DC0((char *)D_80095740);
        func_80048DC0((char *)D_80095744, (unsigned int)D_801B5000 - (unsigned int)regionEnd);
        func_80048DC0((char *)D_80095758);
        func_80048DC0((char *)D_8009575C, D_80200000, D_80225800, 0x25800);
        func_80048DC0((char *)D_80095784, D_801B5000, D_801DA800, 0x25800);
        func_80048DC0((char *)D_800957AC, D_801DA800, D_80200000, 0x25800);
        func_80048DC0((char *)D_800957D4);
        func_80048DC0((char *)D_800957D8, D_8008D360);
        func_80048DC0((char *)D_800957EC, D_8008D364);
        func_80048DC0((char *)D_80095804, D_8008D368);
        func_80048DC0((char *)D_80095818);
        func_80048DC0((char *)D_8009581C, D_800781E4.count, D_800781E4.itemSize,
                     D_800781E4.count * D_800781E4.itemSize);
        func_80048DC0((char *)D_80095840, D_80077AA0.count, D_80077AA0.itemSize,
                     D_80077AA0.count * D_80077AA0.itemSize);
        func_80048DC0((char *)D_80095864, D_80072BE8.count, D_80072BE8.itemSize,
                     D_80072BE8.count * D_80072BE8.itemSize);
        func_80048DC0((char *)D_80095888, D_80072BE0.count, D_80072BE0.itemSize,
                     D_80072BE0.count * D_80072BE0.itemSize);
        func_80048DC0((char *)D_800958AC);
        func_80048DC0((char *)D_800958B0, D_8007CDA0.count, D_8007CDA0.itemSize,
                     D_8007CDA0.count * D_8007CDA0.itemSize);
        func_80048DC0((char *)D_800958D4, D_8007D6A0.count, D_8007D6A0.itemSize,
                     D_8007D6A0.count * D_8007D6A0.itemSize);
        func_80048DC0((char *)D_800958F8, D_8007C548.count, D_8007C548.itemSize,
                     D_8007C548.count * D_8007C548.itemSize);
        if (D_80126B50[6] < D_80126B30[6]) {
            D_80126B50[6] = D_80126B30[6];
        }
        if (D_80126B50[7] < D_80126B30[7]) {
            D_80126B50[7] = D_80126B30[7];
        }
        if (D_80126B50[0] < D_80126B30[0]) {
            D_80126B50[0] = D_80126B30[0];
        }
        if (D_80126B50[2] < D_80126B30[2]) {
            D_80126B50[2] = D_80126B30[2];
        }
        if (D_80126B50[1] < D_80126B30[1]) {
            D_80126B50[1] = D_80126B30[1];
        }
        if (D_80126B50[5] < D_80126B30[5]) {
            D_80126B50[5] = D_80126B30[5];
        }
        if (D_80126B50[4] < D_80126B30[4]) {
            D_80126B50[4] = D_80126B30[4];
        }
        if (D_80126B50[3] < D_80126B30[3]) {
            D_80126B50[3] = D_80126B30[3];
        }
        func_80048DC0((char *)D_8009591C);
        heapBytes = func_8004DCE0();
        availableBytes = func_8004DCE0();
        func_80048DC0((char *)D_80095920, (int)D_8013EBF0, 0x803CE000,
                     0x803CE000 - (int)D_8013EBF0,
                     0x803CE000 - heapBytes - (int)D_8013EBF0, availableBytes);
        func_80048DC0((char *)D_8009595C, D_8013D9C4, D_8013D9C8,
                     D_8013D9C8 - D_8013D9C4,
                     D_8013D9C0 - D_8013D9C4, D_8013D9C8 - D_8013D9C0);
        func_80048DC0((char *)D_80095994, 0x803CE000, 0x80400000, 0x32000,
                     D_80138238->value34);
        func_80048DC0((char *)D_800959C4, D_80126B78, D_80126B74,
                     D_80126B74 - D_80126B78);
        func_80048DC0((char *)D_800959EC);
        func_80048DC0((char *)D_800959F0, D_80126B30[6]);
        func_80048DC0((char *)D_80095A08, D_80126B30[7]);
        func_80048DC0((char *)D_80095A20, D_80126B30[0]);
        func_80048DC0((char *)D_80095A38, D_80126B30[2]);
        func_80048DC0((char *)D_80095A50, D_80126B30[1]);
        func_80048DC0((char *)D_80095A68, D_80126B30[5], D_80126B30[3], D_80126B30[4]);
        func_80048DC0((char *)D_80095A8C);
        func_80048DC0((char *)D_80095A90, D_80126B50[6]);
        func_80048DC0((char *)D_80095AA8, D_80126B50[7]);
        func_80048DC0((char *)D_80095AC0, D_80126B50[0]);
        func_80048DC0((char *)D_80095AD8, D_80126B50[2]);
        func_80048DC0((char *)D_80095AF0, D_80126B50[1]);
        func_80048DC0((char *)D_80095B08, D_80126B30[5], D_80126B30[3], D_80126B30[4]);
        func_80048DC0((char *)D_80095B2C);
    }
}
