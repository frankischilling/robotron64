#include "../../include/sdk_pi_device.h"
#include "../../include/sdk_pi_disk.h"

SdkPiDeviceHandle D_80196390;
SdkPiDiskHandlePrefix *D_80196404;

SdkPiDeviceHandle *func_800676D0(void)
{
    unsigned int mask;

    D_80196390.type = 2;
    D_80196390.baseAddress = 0xA5000000;
    D_80196390.latency = 3;
    D_80196390.pulse = 6;
    D_80196390.pageSize = 6;
    D_80196390.releaseDuration = 2;
    D_80196390.domain = 1;
    *(volatile unsigned int *)0xA4600024 = D_80196390.latency;
    *(volatile unsigned int *)0xA4600028 = D_80196390.pulse;
    *(volatile unsigned int *)0xA460002C = D_80196390.pageSize;
    *(volatile unsigned int *)0xA4600030 = D_80196390.releaseDuration;
    func_800674C0(&D_80196390.transferInfo, 96);
    mask = func_80067560();
    D_80196390.next = D_8008E3EC;
    D_8008E3EC = &D_80196390;
    D_80196404 = (SdkPiDiskHandlePrefix *)&D_80196390;
    func_80067580(mask);
    return &D_80196390;
}
