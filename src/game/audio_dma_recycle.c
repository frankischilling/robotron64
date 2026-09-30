#include "../../include/sdk_audio.h"

extern unsigned int D_8008D790;
extern unsigned int D_8008D794;
extern unsigned int D_8008D838;
extern OSMesgQueue D_80190208;
void func_8005889C(void *message, int first, int second);

void func_80052580(void)
{
    unsigned int i;
    OSMesg message;
    AudioDmaBuffer *buffer;
    AudioDmaBuffer *next;

    for (i = 0; i < D_8008D794; i++) {
        if (func_80062240(&D_80190208, &message, 0) == -1) {
            func_8005889C("DMANOTDONE", 0, 0);
        }
    }
    buffer = D_801901E0.active;
    while (buffer != 0) {
        next = buffer->next;
        if (buffer->lastFrame + D_8008D838 < D_8008D790) {
            if (buffer == D_801901E0.active) {
                D_801901E0.active = buffer->next;
            }
            func_80065AB0((AudioLink *)buffer);
            if (D_801901E0.free != 0) {
                func_80065AE0((AudioLink *)buffer, (AudioLink *)D_801901E0.free);
            } else {
                D_801901E0.free = buffer;
                buffer->next = 0;
                buffer->previous = 0;
            }
        }
        buffer = next;
    }
    D_8008D794 = 0;
    D_8008D790++;
}
