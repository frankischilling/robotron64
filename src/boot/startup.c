/* Startup and the thread 3 loop. See docs/startup.md. */
#include "../../include/scheduler.h"
#include "../../include/audio_runtime.h"
#include "../../include/frame.h"
#include "../../include/graphics_tasks.h"

extern OSThread D_80139280, D_8013A430;
extern unsigned char D_8013B430[], D_8013C5E0[];
extern OSMesgQueue D_8013D7B0;
extern OSMesg D_8013D790[];
void osInitialize(void);
int osPiRawReadIo(unsigned int, unsigned int *);
void osCreatePiManager(int, OSMesgQueue *, OSMesg *, int);
void osSetThreadPri(OSThread *, int);
void func_80048204(void *);
void func_800482A0(void *);

extern void *D_80138260[2];
extern unsigned char D_801B5000[], D_801DA800[];
extern OSMesgQueue D_8013D7C8;
extern OSMesg D_8013D828[];
extern unsigned int D_80000300;
extern unsigned char D_80095420[];
extern void *D_8013823C;
extern int D_80138250, D_8007D8F0;

void func_8004C090(void);
void func_800470F4(void);
void func_8002205C(void *);
void func_80048DDC(void *);
int func_80005DEC(void);
void func_80022D24(void);
void func_800400D0(void);
void func_800466E4(void);
void func_80045514(void);

void func_80048170(void)
{
    unsigned int address;
    unsigned int *current;
    unsigned int *end;
    unsigned int buffer[16];

    osInitialize();
    address = 0x00FFB000;
    current = buffer;
    end = buffer + 16;
    while (current != end) {
        osPiRawReadIo(address, current);
        current++;
        address += 4;
    }
    osCreateThread(&D_80139280, 1, func_80048204, 0, D_8013B430, 10);
    osStartThread(&D_80139280);
}

void func_80048204(void *arg)
{
    osCreatePiManager(150, &D_8013D7B0, D_8013D790, 8);
    osCreateThread(&D_8013A430, 3, func_800482A0, arg, D_8013C5E0, 10);
    osStartThread(&D_8013A430);
    osSetThreadPri(0, 0);
    for (;;) {
    }
}

void func_800482A0(void *arg)
{
    func_80048D90(2);
    D_80138260[0] = D_801B5000;
    D_80138260[1] = D_801DA800;
    osCreateMesgQueue(&D_8013D7C8, D_8013D828, 1);
    if (D_80000300 == TV_MPAL) {
        D_8008E400[28].width = 320;
        D_8008E400[28].xScale *= 320;
        D_8008E400[28].xScale /= 320;
        D_8008E400[28].fields[0].origin = 640;
        func_80050440(&D_801378D0, 28, 1);
    }
    if (D_80000300 == TV_NTSC) {
        D_8008E400[0].width = 320;
        D_8008E400[0].xScale *= 320;
        D_8008E400[0].xScale /= 320;
        D_8008E400[0].fields[0].origin = 640;
        func_80050440(&D_801378D0, 0, 1);
    }
    osViSetSpecialFeatures(VI_GAMMA_OFF);
    osViSetSpecialFeatures(VI_DITHER_FILTER_ON);
    func_8005109C(110, 1);
    func_8004FE44(&D_801378D0);
    func_8004C090();
    func_800470F4();
    func_8002205C(D_80095420);
    func_80048510();
    func_80048DDC(D_8013823C);
    func_80005DEC();
    for (;;) {
        func_80022D24();
    }
}

void func_80048460(void)
{
    func_800489F4();
    func_80048510();
    func_80048DDC(D_8013823C);
    func_800400D0();
    func_800466E4();
    D_80138250 = 1000 / func_800495BC(&D_80138248);
    D_8007D8F0++;
    func_80048BF8();
    func_80045514();
}
