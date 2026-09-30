#include "../../include/sdk_pi_word.h"

extern SdkPiWordHandle *D_8008E3F0[2];
unsigned int func_800606A0(void *address);

int func_80067990(SdkPiWordHandle *handle, int direction,
                  unsigned int address, void *dramAddress, unsigned int size)
{
    unsigned int status;
    unsigned int domain;

    status = *(volatile unsigned int *)0xA4600010;
    while (status & 3) {
        status = *(volatile unsigned int *)0xA4600010;
    }
    domain = handle->domain;
    if (D_8008E3F0[domain] != handle) {
        SdkPiWordHandle *current = D_8008E3F0[domain];

        if (domain == 0) {
            if (current->latency != handle->latency) {
                *(volatile unsigned int *)0xA4600014 = handle->latency;
            }
            if (current->pageSize != handle->pageSize) {
                *(volatile unsigned int *)0xA460001C = handle->pageSize;
            }
            if (current->releaseDuration != handle->releaseDuration) {
                *(volatile unsigned int *)0xA4600020 = handle->releaseDuration;
            }
            if (current->pulse != handle->pulse) {
                *(volatile unsigned int *)0xA4600018 = handle->pulse;
            }
        } else {
            if (current->latency != handle->latency) {
                *(volatile unsigned int *)0xA4600024 = handle->latency;
            }
            if (current->pageSize != handle->pageSize) {
                *(volatile unsigned int *)0xA460002C = handle->pageSize;
            }
            if (current->releaseDuration != handle->releaseDuration) {
                *(volatile unsigned int *)0xA4600030 = handle->releaseDuration;
            }
            if (current->pulse != handle->pulse) {
                *(volatile unsigned int *)0xA4600028 = handle->pulse;
            }
        }
        D_8008E3F0[domain] = handle;
    }
    *(volatile unsigned int *)0xA4600000 = func_800606A0(dramAddress);
    *(volatile unsigned int *)0xA4600004 = (handle->baseAddress | address) & 0x1FFFFFFF;
    switch (direction) {
    case 0:
        *(volatile unsigned int *)0xA460000C = size - 1;
        break;
    case 1:
        *(volatile unsigned int *)0xA4600008 = size - 1;
        break;
    default:
        return -1;
    }
    return 0;
}
