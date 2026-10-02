#ifndef ROBOTRON_RENDERER_DIAGNOSTIC_INTERNAL_H
#define ROBOTRON_RENDERER_DIAGNOSTIC_INTERNAL_H

#include "graphics_state_internal.h"
#include "renderer_peak_metrics.h"

/* Only the count and element-size prefix is recovered for these pools. */
typedef struct DiagnosticResourcePrefix {
    int count;
    int itemSize;
} DiagnosticResourcePrefix;

typedef struct DiagnosticDisplayListPrefix {
    unsigned char unknown00[0x34];
    unsigned int value34;
} DiagnosticDisplayListPrefix;

typedef char DiagnosticResourcePrefixMustBe8Bytes[
    sizeof(DiagnosticResourcePrefix) == 8 ? 1 : -1];

extern int D_8007D8F0;
extern const char D_8007D6B0[32];
extern unsigned char D_80000450[];
extern unsigned char D_800518E0[];
extern unsigned char D_80072B30[];
extern unsigned char D_8008D780[];
extern unsigned char D_80097290[];
extern unsigned char D_80190170[];
extern unsigned char D_801B5000[];
extern unsigned char D_801DA800[];
extern unsigned char D_80200000[];
extern unsigned char D_80225800[];
extern int D_8008D360;
extern int D_8008D364;
extern int D_8008D368;
extern DiagnosticResourcePrefix D_800781E4;
extern DiagnosticResourcePrefix D_80077AA0;
extern DiagnosticResourcePrefix D_80072BE8;
extern DiagnosticResourcePrefix D_80072BE0;
extern DiagnosticResourcePrefix D_8007CDA0;
extern DiagnosticResourcePrefix D_8007D6A0;
extern DiagnosticResourcePrefix D_8007C548;
extern GraphicsFrameCounters D_80126B50;
extern int *D_8013EBF0;
extern unsigned char *D_8013D9C8;
extern DiagnosticDisplayListPrefix *D_80138238;

extern const char D_80095640[];
extern const char D_8009568C[];
extern const char D_80095694[];
extern const char D_800956A0[];
extern const char D_800956AC[];
extern const char D_800956BC[];
extern const char D_800956C8[];
extern const char D_800956F0[];
extern const char D_80095718[];
extern const char D_80095740[];
extern const char D_80095744[];
extern const char D_80095758[];
extern const char D_8009575C[];
extern const char D_80095784[];
extern const char D_800957AC[];
extern const char D_800957D4[];
extern const char D_800957D8[];
extern const char D_800957EC[];
extern const char D_80095804[];
extern const char D_80095818[];
extern const char D_8009581C[];
extern const char D_80095840[];
extern const char D_80095864[];
extern const char D_80095888[];
extern const char D_800958AC[];
extern const char D_800958B0[];
extern const char D_800958D4[];
extern const char D_800958F8[];
extern const char D_8009591C[];
extern const char D_80095920[];
extern const char D_8009595C[];
extern const char D_80095994[];
extern const char D_800959C4[];
extern const char D_800959EC[];
extern const char D_800959F0[];
extern const char D_80095A08[];
extern const char D_80095A20[];
extern const char D_80095A38[];
extern const char D_80095A50[];
extern const char D_80095A68[];
extern const char D_80095A8C[];
extern const char D_80095A90[];
extern const char D_80095AA8[];
extern const char D_80095AC0[];
extern const char D_80095AD8[];
extern const char D_80095AF0[];
extern const char D_80095B08[];
extern const char D_80095B2C[];

void func_8004C6E0(void);

#endif
