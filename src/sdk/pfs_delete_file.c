#include "../../include/sdk_pfs_internal.h"

int func_800643E0(SdkPfs *pfs, unsigned short companyCode, unsigned int gameCode,
                  unsigned char *gameName, unsigned char *extension)
{
    int fileNumber;
    int index;
    int ret;
    SdkPfsInode inode;
    SdkPfsDirectory directory;
    unsigned short sum;
    SdkPfsInodeUnit lastPage;
    unsigned char startPage;
    unsigned char bank;

    sum = 0;
    if (companyCode == 0 || gameCode == 0)
        return SDK_PFS_ERR_INVALID;
    if ((pfs->status & SDK_PFS_INITIALIZED) == 0)
        return SDK_PFS_ERR_INVALID;
    SDK_PFS_CHECK_ID(pfs);
    SDK_PFS_SET_ACTIVE_BANK_ZERO(pfs);
    SDK_PFS_ERRCK(func_80062380(pfs, companyCode, gameCode, gameName, extension,
                               &fileNumber));

    if (fileNumber == -1)
        return SDK_PFS_ERR_INVALID;
    SDK_PFS_ERRCK(func_80069630(pfs->queue, pfs->channel,
                               pfs->directoryTable + fileNumber,
                               (unsigned char *)&directory));

    startPage = directory.startPage.inode.page;

    for (bank = directory.startPage.inode.bank; bank < pfs->banks;) {
        SDK_PFS_ERRCK(func_8006929C(pfs, &inode, SDK_PFS_READ, bank));
        SDK_PFS_ERRCK(func_800646C0(pfs, &inode, startPage, &sum, bank, &lastPage, 1));
        SDK_PFS_ERRCK(func_8006929C(pfs, &inode, SDK_PFS_WRITE, bank));
        if (lastPage.pageNumber == 1)
            break;
        bank = lastPage.inode.bank;
        startPage = lastPage.inode.page;
    }

    if (bank >= pfs->banks)
        return SDK_PFS_ERR_INCONSISTENT;

    directory.gameCode = 0;
    directory.companyCode = 0;
    directory.startPage.pageNumber = 0;
    directory.dataSum = 0;
    for (index = 0; index < SDK_PFS_NAME_LENGTH; index++) {
        directory.gameName[index] = 0;
    }
    for (index = 0; index < SDK_PFS_EXT_LENGTH; index++) {
        directory.extension[index] = 0;
    }
    directory.status = 0;
    ret = func_8006A6A0(pfs->queue, pfs->channel, pfs->directoryTable + fileNumber,
                        (unsigned char *)&directory, 0);

    return ret;
}

int func_800646C0(SdkPfs *pfs, SdkPfsInode *inode, unsigned char startPage,
                  unsigned short *sum, unsigned char bank, SdkPfsInodeUnit *lastPage,
                  int flag)
{
    SdkPfsInodeUnit nextPage;
    SdkPfsInodeUnit oldPage;
    int ret;
    int offset;

    ret = 0;
    nextPage = inode->pages[startPage];
    if (nextPage.pageNumber != 1) {
        if (nextPage.inode.bank > 0)
            offset = 1;
        else
            offset = pfs->inodeStartPage;
    } else {
        if (bank > 0)
            offset = 1;
        else
            offset = pfs->inodeStartPage;
    }
    if (nextPage.inode.page < offset && nextPage.pageNumber != 1)
        return SDK_PFS_ERR_INCONSISTENT;
    *lastPage = nextPage;
    if (flag == 1)
        inode->pages[startPage].pageNumber = 3;

    SDK_PFS_ERRCK(func_800648F8(pfs, startPage, sum, bank));
    if (nextPage.pageNumber == 1)
        return 0;
    while (nextPage.pageNumber >= pfs->inodeStartPage) {
        oldPage = nextPage;
        nextPage = inode->pages[nextPage.inode.page];
        inode->pages[oldPage.inode.page].pageNumber = 3;

        SDK_PFS_ERRCK(func_800648F8(pfs, oldPage.inode.page, sum, bank));
        if (nextPage.inode.bank != bank)
            break;
    }
    if (nextPage.pageNumber >= pfs->inodeStartPage)
        inode->pages[nextPage.inode.page].pageNumber = 3;
    *lastPage = nextPage;
    return 0;
}

int func_800648F8(SdkPfs *pfs, unsigned char pageNumber, unsigned short *sum,
                  unsigned char bank)
{
    int index;
    int ret;
    unsigned char data[32];

    ret = 0;
    pfs->activeBank = bank;
    SDK_PFS_ERRCK(func_800695BC(pfs));
    for (index = 0; index < SDK_PFS_BLOCKS_PER_PAGE; index++) {
        ret = func_80069630(pfs->queue, pfs->channel,
                            pageNumber * SDK_PFS_BLOCKS_PER_PAGE + index, data);
        if (ret != 0) {
            pfs->activeBank = 0;
            func_800695BC(pfs);
            return ret;
        }
        *sum = *sum + func_800688D0(data, sizeof(data));
    }
    pfs->activeBank = 0;
    ret = func_800695BC(pfs);
    return ret;
}
