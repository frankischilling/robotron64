#include "../../include/sdk_pfs.h"

int func_80062C28(SdkPfs *pfs, int pageNumber, unsigned char *data, unsigned char bank);

int func_80062540(SdkPfs *pfs, unsigned short companyCode, unsigned int gameCode,
                  unsigned char *gameName, unsigned char *extension, int fileSize,
                  int *fileNumber)
{
    int startPage;
    int declared;
    int lastPage;
    int oldLastPage;
    int index;
    int ret;
    int filePages;
    SdkPfsInode inode;
    SdkPfsInode backupInode;
    SdkPfsDirectory directory;
    unsigned char bank;
    unsigned char oldBank;
    int firstTime;
    int bytes;
    SdkPfsInodeUnit firstPage;

    oldLastPage = 0;
    ret = 0;
    oldBank = 0;
    firstTime = 0;

    if (companyCode == 0 || gameCode == 0)
        return SDK_PFS_ERR_INVALID;

    filePages = (fileSize + 255) / (SDK_PFS_BLOCK_SIZE * SDK_PFS_BLOCKS_PER_PAGE);
    if ((pfs->status & SDK_PFS_INITIALIZED) == 0)
        return SDK_PFS_ERR_INVALID;

    SDK_PFS_CHECK_ID(pfs);

    ret = func_80062380(pfs, companyCode, gameCode, gameName, extension, fileNumber);
    if (ret != 0 && ret != SDK_PFS_ERR_INVALID)
        return ret;

    if (*fileNumber != -1)
        return SDK_PFS_ERR_EXIST;

    ret = func_80064140(pfs, &bytes);
    if (fileSize > bytes)
        return SDK_PFS_DATA_FULL;

    if (filePages != 0) {
        ret = func_80062380(pfs, 0, 0, 0, 0, fileNumber);
        if (ret != 0 && ret != SDK_PFS_ERR_INVALID)
            return ret;
        if (*fileNumber == -1)
            return SDK_PFS_DIR_FULL;

        for (bank = 0; bank < pfs->banks; bank++) {
            SDK_PFS_ERRCK(func_8006929C(pfs, &inode, 0, bank));
            SDK_PFS_ERRCK(func_800629C4(pfs, &inode, filePages, &startPage, bank,
                                       &declared, &lastPage));
            if (startPage != -1) {
                if (firstTime == 0) {
                    firstPage.inode.page = startPage;
                    firstPage.inode.bank = bank;
                } else {
                    backupInode.pages[oldLastPage].inode.bank = bank;
                    backupInode.pages[oldLastPage].inode.page = startPage;
                    SDK_PFS_ERRCK(func_8006929C(pfs, &backupInode, 1, oldBank));
                }

                for (index = 0; index < SDK_PFS_INODE_PAGES; index++)
                    backupInode.pages[index].pageNumber = inode.pages[index].pageNumber;
                oldLastPage = lastPage;
                oldBank = bank;
                firstTime++;
                if (filePages > declared)
                    filePages = filePages - declared;
                else {
                    filePages = 0;
                    break;
                }
            }
        }
        if (filePages > 0 || startPage == -1)
            return SDK_PFS_ERR_INCONSISTENT;

        backupInode.pages[oldLastPage].inode.bank = bank;
        backupInode.pages[oldLastPage].inode.page = startPage;
        SDK_PFS_ERRCK(func_8006929C(pfs, &backupInode, 1, oldBank));
        directory.startPage = firstPage;
        directory.companyCode = companyCode;
        directory.gameCode = gameCode;
        directory.dataSum = 0;
        for (index = 0; index < SDK_PFS_NAME_LENGTH; index++)
            directory.gameName[index] = *gameName++;
        for (index = 0; index < SDK_PFS_EXT_LENGTH; index++)
            directory.extension[index] = *extension++;
        SDK_PFS_ERRCK(func_8006A6A0(pfs->queue, pfs->channel,
                                   *fileNumber + pfs->directoryTable,
                                   (unsigned char *)&directory, 0));
        return ret;
    }
    return SDK_PFS_ERR_INVALID;
}

int func_800629C4(SdkPfs *pfs, SdkPfsInode *inode, int filePages, int *firstPage,
                  unsigned char bank, int *declared, int *lastPage)
{
    int index;
    int startPage;
    int oldPage;
    unsigned char temp[SDK_PFS_BLOCK_SIZE];
    int tempIndex;
    int ret;
    int offset;

    ret = 0;
    if (bank > 0)
        offset = 1;
    else
        offset = pfs->inodeStartPage;
    for (index = offset; index < SDK_PFS_INODE_PAGES; index++) {
        if (inode->pages[index].pageNumber == 3)
            break;
    }
    if (index == SDK_PFS_INODE_PAGES) {
        *firstPage = -1;
        return ret;
    }
    for (tempIndex = 0; tempIndex < SDK_PFS_BLOCK_SIZE; tempIndex++)
        temp[tempIndex] = 0;
    startPage = index;
    *declared = 1;
    oldPage = index++;
    while (filePages > *declared && index < SDK_PFS_INODE_PAGES) {
        if (inode->pages[index].pageNumber == 3) {
            inode->pages[oldPage].inode.bank = bank;
            inode->pages[oldPage].inode.page = index;
            SDK_PFS_ERRCK(func_80062C28(pfs, oldPage, temp, bank));
            oldPage = index;
            (*declared)++;
        }
        index++;
    }
    *firstPage = startPage;
    if (index == SDK_PFS_INODE_PAGES) {
        if (filePages > *declared) {
            *lastPage = oldPage;
            return ret;
        }
    }
    inode->pages[oldPage].pageNumber = 1;
    ret = func_80062C28(pfs, oldPage, temp, bank);
    *lastPage = 0;
    return ret;
}

int func_80062C28(SdkPfs *pfs, int pageNumber, unsigned char *data, unsigned char bank)
{
    int index;
    int ret;
    ret = 0;
    pfs->activeBank = bank;
    SDK_PFS_ERRCK(func_800695BC(pfs));
    for (index = 0; index < SDK_PFS_BLOCKS_PER_PAGE; index++) {
        ret = func_8006A6A0(pfs->queue, pfs->channel,
                           pageNumber * SDK_PFS_BLOCKS_PER_PAGE + index, data, 0);
        if (ret != 0)
            break;
    }
    pfs->activeBank = 0;
    ret = func_800695BC(pfs);
    return ret;
}
