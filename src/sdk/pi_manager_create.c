#include "../../include/sdk_pi_dma.h"

SdkDeviceManager D_8008E3D0 = {0};
SdkPiDeviceHandle *D_8008E3EC = 0;
SdkPiWordHandle *D_8008E3F0[2] = {(SdkPiWordHandle *)&D_80196310, (SdkPiWordHandle *)&D_80196390};
OSThread D_80193B40;
unsigned char D_80193CF0[0x1000];
OSMesgQueue D_80194CF0;
OSMesg D_80194D08[1];
extern int D_8008F1C0;
extern OSMesgQueue D_80196418;
void func_800677D0(void);
int func_800678B0(int direction, unsigned int address, void *dramAddress, unsigned int size);
void func_80067BC0(void *argument);

void osCreatePiManager(int priority, OSMesgQueue *commandQueue, OSMesg *messages, int capacity)
{
    unsigned int mask;
    int previousPriority;
    int currentPriority;

    if (!D_8008E3D0.active) {
        osCreateMesgQueue(commandQueue, messages, capacity);
        osCreateMesgQueue(&D_80194CF0, D_80194D08, 1);
        if (!D_8008F1C0) {
            func_800677D0();
        }
        osSetEventMesg(8, &D_80194CF0, (OSMesg)0x22222222);
        previousPriority = -1;
        currentPriority = func_80067890(0);
        if (currentPriority < priority) {
            previousPriority = currentPriority;
            osSetThreadPri(0, priority);
        }
        mask = func_80067560();
        D_8008E3D0.active = 1;
        D_8008E3D0.thread = &D_80193B40;
        D_8008E3D0.commandQueue = commandQueue;
        D_8008E3D0.eventQueue = &D_80194CF0;
        D_8008E3D0.accessQueue = &D_80196418;
        D_8008E3D0.dma = func_800678B0;
        D_8008E3D0.extendedDma = func_80067990;
        osCreateThread(&D_80193B40, 0, func_80067BC0, &D_8008E3D0,
                       D_80193CF0 + sizeof(D_80193CF0), priority);
        osStartThread(&D_80193B40);
        func_80067580(mask);
        if (previousPriority != -1) {
            osSetThreadPri(0, previousPriority);
        }
    }
}
