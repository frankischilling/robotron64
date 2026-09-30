#include "../../include/sdk_pfs_internal.h"

int func_80064290(SdkPfs *pfs, int *maxFiles, int *filesUsed)
{
    int index;
    int ret;
    SdkPfsDirectory directory;
    int files;

    files = 0;
    if ((pfs->status & SDK_PFS_INITIALIZED) == 0)
        return SDK_PFS_ERR_INVALID;
    SDK_PFS_CHECK_ID(pfs);
    SDK_PFS_SET_ACTIVE_BANK_ZERO(pfs);
    for (index = 0; index < pfs->directorySize; index++) {
        SDK_PFS_ERRCK(func_80069630(pfs->queue, pfs->channel,
                                   pfs->directoryTable + index,
                                   (unsigned char *)&directory));
        if (directory.companyCode != 0 && directory.gameCode != 0)
            files++;
    }
    *filesUsed = files;
    *maxFiles = pfs->directorySize;
    return 0;
}
