/* Nonmatching candidate; excluded from the ROM build. See docs/startup.md. */
typedef struct OSThread OSThread;
typedef struct OSMesgQueue OSMesgQueue;
typedef void *OSMesg;
extern OSThread D_80139280, D_8013A430;
extern unsigned char D_8013B430[], D_8013C5E0[];
extern OSMesgQueue D_8013D7B0;
extern OSMesg D_8013D790[];
void osInitialize(void);
int osPiRawReadIo(unsigned int, unsigned int *);
void osCreateThread(OSThread *, int, void (*)(void *), void *, void *, int);
void osStartThread(OSThread *);
void osCreatePiManager(int, OSMesgQueue *, OSMesg *, int);
void osSetThreadPri(OSThread *, int);
void func_80048204(void *);
void func_800482A0(void *);

void func_80048170(void)
{
    unsigned int buffer[16];
    int i;

    osInitialize();
    for (i = 0; i < 16; i++) {
        osPiRawReadIo(0x00FFB000 + i * 4, &buffer[i]);
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
