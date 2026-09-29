#include "../../include/sdk_pfs_internal.h"

int func_80061D70(OSMesgQueue *queue, SdkPfs *pfs, int channel)
{
    int index;
    int ret;
    unsigned short checksum;
    unsigned short invertedChecksum;
    unsigned char temp[SDK_PFS_BLOCK_SIZE];
    SdkPfsPackId *id;
    SdkPfsPackId newId;

    ret = 0;
    func_80069A10();
    ret = func_80069B30(queue, channel);
    func_80069A54();
    if (ret != 0)
        return ret;

    pfs->queue = queue;
    pfs->channel = channel;
    pfs->status = 0;
    pfs->activeBank = 0;
    SDK_PFS_ERRCK(func_800695BC(pfs));
    func_8006892C((unsigned short *)temp, &checksum, &invertedChecksum);
    id = (SdkPfsPackId *)temp;
    if (id->checksum != checksum || id->invertedChecksum != invertedChecksum) {
        SDK_PFS_ERRCK(func_80068DAC(pfs, id));
        if (ret != 0)
            return ret;
    }
    if ((id->deviceId & 1) == 0) {
        SDK_PFS_ERRCK(func_80068994(pfs, id, &newId));
        id = &newId;
        if ((id->deviceId & 1) == 0)
            return SDK_PFS_ERR_DEVICE;
    }
    for (index = 0; index < SDK_PFS_BLOCK_SIZE; index++) {
        pfs->id[index] = ((unsigned char *)id)[index];
    }
    pfs->version = id->version;
    pfs->banks = id->banks;
    pfs->inodeStartPage = pfs->banks * 2 + 3;
    pfs->directorySize = 16;
    pfs->inodeTable = 8;
    pfs->mirrorInodeTable = pfs->banks * SDK_PFS_BLOCKS_PER_PAGE + 8;
    pfs->directoryTable = pfs->mirrorInodeTable + pfs->banks * SDK_PFS_BLOCKS_PER_PAGE;
    SDK_PFS_ERRCK(func_80069630(pfs->queue, pfs->channel, 7, pfs->label));
    ret = func_80069C40(pfs);
    pfs->status |= SDK_PFS_INITIALIZED;
    return ret;
}
