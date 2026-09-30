#include "../../include/audio_io.h"

extern int D_8008D7A4;
extern OSMesgQueue D_80190228;

int func_80062240(OSMesgQueue *queue, OSMesg *message, int flags);

unsigned int func_800518E0(unsigned int value)
{
    return value * value;
}

void func_800518F0(unsigned char *destination, unsigned char value, unsigned int count)
{
    while (count--) {
        *destination++ = value;
    }
}

unsigned int func_80051924(unsigned int deviceAddress, void *destination, unsigned int count)
{
    AudioTransferRequest request;
    OSMesg message;

    if (D_8008D7A4 == 0) {
        return 0;
    }
    if (count == 0) {
        return 0;
    }
    func_80065790(destination, count);
    func_80065840(&request, 1, 0, deviceAddress, destination, count, &D_80190228);
    func_80062240(&D_80190228, &message, 1);
    return count;
}

int func_800519C0(int value, float frequency)
{
    return (int)((float)value * (frequency / 1000.0f)) & ~7;
}
