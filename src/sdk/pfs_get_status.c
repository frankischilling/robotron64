#include "../../include/sdk_pfs_internal.h"

int func_80069B30(OSMesgQueue *queue, int channel)
{
    int ret;
    OSMesg message;
    unsigned char pattern;
    SdkControllerStatus status[4];

    ret = 0;
    func_80061BA0(0);
    ret = func_80069A80(1, &D_80194D20);
    func_80062240(queue, &message, 1);
    ret = func_80069A80(0, &D_80194D20);
    func_80062240(queue, &message, 1);
    func_80061C9C(&pattern, status);
    if ((status[channel].status & 1) != 0 && (status[channel].status & 2) != 0)
        return SDK_PFS_ERR_NEW_PACK;
    if (status[channel].error != 0 || (status[channel].status & 1) == 0)
        return SDK_PFS_ERR_NOPACK;
    if ((status[channel].status & 4) != 0)
        return SDK_PFS_ERR_CONTRFAIL;
    return ret;
}
