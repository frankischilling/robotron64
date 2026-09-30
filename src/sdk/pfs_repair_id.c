#include "../../include/sdk_pfs_internal.h"

int func_800617A0(SdkPfs *pak)
{
    int index;
    unsigned short checksum;
    unsigned short invertedChecksum;
    unsigned char bytes[32];
    SdkPfsPackId repaired;
    int ret;
    SdkPfsPackId *id;

    SDK_PFS_SET_ACTIVE_BANK_ZERO(pak);
    SDK_PFS_ERRCK(func_80069630(pak->queue, pak->channel, 1, bytes));
    func_8006892C((unsigned short *)bytes, &checksum, &invertedChecksum);
    id = (SdkPfsPackId *)bytes;
    if (id->checksum != checksum || id->invertedChecksum != invertedChecksum) {
        ret = func_80068DAC(pak, id);
        if (ret == SDK_PFS_ERR_ID_FATAL) {
            SDK_PFS_ERRCK(func_80068994(pak, id, &repaired));
            id = &repaired;
        } else if (ret != 0) {
            return ret;
        }
    }
    if ((id->deviceId & 1) == 0) {
        SDK_PFS_ERRCK(func_80068994(pak, id, &repaired));
        id = &repaired;
        if ((id->deviceId & 1) == 0) {
            return SDK_PFS_ERR_DEVICE;
        }
    }
    for (index = 0; index < 32; index++) {
        pak->id[index] = ((unsigned char *)id)[index];
    }
    pak->version = id->version;
    pak->banks = id->banks;
    pak->inodeStartPage = pak->banks * 2 + 3;
    pak->directorySize = 16;
    pak->inodeTable = 8;
    pak->mirrorInodeTable = pak->banks * 8 + 8;
    pak->directoryTable = pak->mirrorInodeTable + pak->banks * 8;
    SDK_PFS_ERRCK(func_80069630(pak->queue, pak->channel, 7, pak->label));
    return 0;
}
