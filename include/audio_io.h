#ifndef ROBOTRON_AUDIO_IO_H
#define ROBOTRON_AUDIO_IO_H

#include "scheduler.h"

typedef struct AudioTransferRequest {
    unsigned short type;
    unsigned char priority;
    unsigned char status;
    OSMesgQueue *completionQueue;
    void *destination;
    unsigned int deviceAddress;
    unsigned int size;
    void *unknown14;
} AudioTransferRequest;

unsigned int func_800518E0(unsigned int value);
void func_800518F0(unsigned char *destination, unsigned char value, unsigned int count);
unsigned int func_80051924(unsigned int deviceAddress, void *destination, unsigned int count);
int func_800519C0(int value, float frequency);

void func_80065790(void *destination, unsigned int count);
int func_80065B70(void *address, unsigned int size);
unsigned int func_80065C20(void);
int func_80065840(AudioTransferRequest *request, int priority, int direction,
                 unsigned int deviceAddress, void *destination,
                 unsigned int count, OSMesgQueue *completionQueue);

#endif
