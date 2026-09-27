/* Initial PI reads and thread handoff. See docs/startup.md. */
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
