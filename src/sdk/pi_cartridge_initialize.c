#include "../../include/sdk_pi_device.h"

SdkPiDeviceHandle D_80196310;

SdkPiDeviceHandle *func_800675E0(void)
{
    unsigned int domain;
    unsigned int mask;

    domain = 0;
    if (D_80196310.baseAddress == 0xB0000000) {
        return &D_80196310;
    }
    D_80196310.type = 0;
    D_80196310.baseAddress = 0xB0000000;
    osPiRawReadIo(0, &domain);
    D_80196310.latency = domain & 0xFF;
    D_80196310.pulse = (domain >> 8) & 0xFF;
    D_80196310.pageSize = (domain >> 16) & 0xF;
    D_80196310.releaseDuration = (domain >> 20) & 0xF;
    D_80196310.domain = 0;
    func_800674C0(&D_80196310.transferInfo, 96);
    mask = func_80067560();
    D_80196310.next = D_8008E3EC;
    D_8008E3EC = &D_80196310;
    func_80067580(mask);
    return &D_80196310;
}
