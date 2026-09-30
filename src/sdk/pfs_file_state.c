#include "../../include/sdk_pfs_internal.h"

int func_800649F0(SdkPfs *pfs, int fileNumber, SdkPfsState *state)
{
    int ret;
    int pages;
    SdkPfsInode inode;
    SdkPfsDirectory directory;
    SdkPfsInodeUnit nextPage;
    int index;
    unsigned char bank;
    unsigned char startPage;

    if (fileNumber >= pfs->directorySize || fileNumber < 0)
        return SDK_PFS_ERR_INVALID;
    if ((pfs->status & SDK_PFS_INITIALIZED) == 0)
        return SDK_PFS_ERR_INVALID;
    SDK_PFS_CHECK_ID(pfs);
    SDK_PFS_SET_ACTIVE_BANK_ZERO(pfs);

    SDK_PFS_ERRCK(func_80069630(pfs->queue, pfs->channel,
                               pfs->directoryTable + fileNumber,
                               (unsigned char *)&directory));
    if (directory.companyCode == 0 || directory.gameCode == 0)
        return SDK_PFS_ERR_INVALID;
    if (directory.startPage.pageNumber < pfs->inodeStartPage)
        return SDK_PFS_ERR_INCONSISTENT;
    pages = 0;
    startPage = directory.startPage.inode.page;
    bank = directory.startPage.inode.bank;
    while (bank < pfs->banks) {
        SDK_PFS_ERRCK(func_8006929C(pfs, &inode, SDK_PFS_READ, bank));
        nextPage = inode.pages[startPage];
        pages++;
        while (nextPage.pageNumber >= pfs->inodeStartPage) {
            pages++;
            nextPage = inode.pages[nextPage.inode.page];
            if (nextPage.inode.bank != bank) {
                bank = nextPage.inode.bank;
                startPage = nextPage.inode.page;
                break;
            }
        }
        if (nextPage.pageNumber == 1)
            break;
    }
    if (nextPage.pageNumber != 1)
        return SDK_PFS_ERR_INCONSISTENT;

    state->fileSize = pages << SDK_PFS_PAGE_SHIFT;
    state->companyCode = directory.companyCode;
    state->gameCode = directory.gameCode;
    for (index = 0; index < SDK_PFS_NAME_LENGTH; index++)
        state->gameName[index] = directory.gameName[index];
    for (index = 0; index < SDK_PFS_EXT_LENGTH; index++)
        state->extension[index] = directory.extension[index];
    return 0;
}
