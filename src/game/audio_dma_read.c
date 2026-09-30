#include "../../include/sdk_audio.h"
#include "../../include/sdk_pi_dma.h"

extern unsigned int D_8008D790;
extern unsigned int D_8008D794;
extern unsigned int D_8008D830;
extern OSMesgQueue D_80190208;
extern SdkPiDmaMessage *D_80190220;
void func_8005889C(void *message, int first, int second);
unsigned int func_800606A0(void *address);

int func_80052378(int deviceAddress, int length, void *state)
{
    unsigned char *data;
    int offset;
    AudioDmaBuffer *buffer;
    AudioDmaBuffer *head;
    int end;
    AudioDmaBuffer *previous;

    buffer = D_801901E0.active;
    previous = 0;
    while (buffer != 0) {
        end = buffer->deviceAddress + D_8008D830;
        if (deviceAddress < buffer->deviceAddress) {
            break;
        }
        if (end >= deviceAddress + length) {
            buffer->lastFrame = D_8008D790;
            return func_800606A0(buffer->data + deviceAddress - buffer->deviceAddress);
        }
        previous = buffer;
        buffer = buffer->next;
    }
    buffer = D_801901E0.free;
    if (buffer == 0) {
        func_8005889C("DMAPTRNULL", 0, 0);
        return func_800606A0(D_801901E0.active);
    }
    D_801901E0.free = buffer->next;
    func_80065AB0((AudioLink *)buffer);
    if (previous != 0) {
        func_80065AE0((AudioLink *)buffer, (AudioLink *)previous);
    } else if ((head = D_801901E0.active) != 0) {
        D_801901E0.active = buffer;
        buffer->next = head;
        buffer->previous = 0;
        head->previous = buffer;
    } else {
        D_801901E0.active = buffer;
        buffer->next = 0;
        buffer->previous = 0;
    }
    data = buffer->data;
    offset = deviceAddress & 1;
    deviceAddress -= offset;
    buffer->deviceAddress = deviceAddress;
    buffer->lastFrame = D_8008D790;
    func_80065840(&D_80190220[D_8008D794++], 1, 0, deviceAddress,
                  data, D_8008D830, &D_80190208);
    return func_800606A0(data) + offset;
}
