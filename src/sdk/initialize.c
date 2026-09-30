#include "../../include/sdk_time.h"

typedef struct SdkExceptionVector {
    unsigned int instructions[4];
} SdkExceptionVector;

typedef char SdkExceptionVectorMustBe16Bytes[
    sizeof(SdkExceptionVector) == 16 ? 1 : -1];

SdkTime D_8008E3B0 = 62500000;
int D_8008E3B8 = 48681812;
unsigned int D_8008E3BC = 0;
unsigned int D_8008E3C0 = 0x3FFF01;
unsigned int D_80193B30;
extern void func_80066A50(void);
extern unsigned int D_80000300;
extern unsigned int D_8000030C;
extern unsigned char D_8000031C[64];

void func_80066980(unsigned int);
unsigned int func_80066990(void);
unsigned int func_800669A0(unsigned int);
int func_800669B0(unsigned int, unsigned int *);
int func_80066A00(unsigned int, unsigned int);
void func_80067360(void *, unsigned int);
void func_800673E0(void *, unsigned int);
void func_80067460(void);
int osPiRawReadIo(unsigned int, unsigned int *);
void func_800674C0(void *, unsigned int);

void osInitialize(void)
{
    unsigned int pifData;
    unsigned int clock = 0;

    D_80193B30 = 1;
    func_80066980(func_80066990() | 0x20000000);
    func_800669A0(0x01000800);
    while (func_800669B0(0x1FC007FC, &pifData)) {
    }
    while (func_80066A00(0x1FC007FC, pifData | 8)) {
    }
    *(SdkExceptionVector *)0x80000000 = *(SdkExceptionVector *)func_80066A50;
    *(SdkExceptionVector *)0x80000080 = *(SdkExceptionVector *)func_80066A50;
    *(SdkExceptionVector *)0x80000100 = *(SdkExceptionVector *)func_80066A50;
    *(SdkExceptionVector *)0x80000180 = *(SdkExceptionVector *)func_80066A50;
    func_80067360((void *)0x80000000, 0x190);
    func_800673E0((void *)0x80000000, 0x190);
    func_80067460();
    osPiRawReadIo(4, &clock);
    clock &= ~0xF;
    if (clock != 0) {
        D_8008E3B0 = clock;
    }
    D_8008E3B0 = D_8008E3B0 * 3 / 4;
    if (D_8000030C == 0) {
        func_800674C0(D_8000031C, 64);
    }
    if (D_80000300 == 0) {
        D_8008E3B8 = 49656530;
    } else if (D_80000300 == 2) {
        D_8008E3B8 = 48628316;
    } else {
        D_8008E3B8 = 48681812;
    }
}
