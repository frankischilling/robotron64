#include "../../include/sdk_pfs.h"

int func_80062380(SdkPfs *pfs, unsigned short companyCode, unsigned int gameCode,
                  unsigned char *gameName, unsigned char *extension, int *fileNumber)
{
    int directoryIndex;
    int index;
    SdkPfsDirectory directory;
    int ret;
    int fail;

    ret = 0;
    SDK_PFS_CHECK_ID(pfs);
    for (directoryIndex = 0; directoryIndex < pfs->directorySize; directoryIndex++) {
        SDK_PFS_ERRCK(func_80069630(pfs->queue, pfs->channel,
                                   pfs->directoryTable + directoryIndex,
                                   (unsigned char *)&directory));
        if ((directory.companyCode == companyCode) && directory.gameCode == gameCode) {
            fail = 0;
            if (gameName != 0) {
                for (index = 0; index < SDK_PFS_NAME_LENGTH; index++) {
                    if (directory.gameName[index] != gameName[index]) {
                        fail = 1;
                        break;
                    }
                }
            }
            if (extension != 0 && !fail) {
                for (index = 0; index < SDK_PFS_EXT_LENGTH; index++) {
                    if (directory.extension[index] != extension[index]) {
                        fail = 1;
                        break;
                    }
                }
            }
            if (!fail) {
                *fileNumber = directoryIndex;
                return ret;
            }
        }
    }
    *fileNumber = -1;
    return SDK_PFS_ERR_INVALID;
}
