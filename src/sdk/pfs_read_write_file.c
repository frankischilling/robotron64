#include "../../include/sdk_pfs.h"

static int func_80062CF0(SdkPfs *pfs, unsigned char *bank, SdkPfsInode *inode,
                         SdkPfsInodeUnit *page)
{
    int ret;
    if (*bank != page->inode.bank) {
        *bank = page->inode.bank;
        SDK_PFS_ERRCK(func_8006929C(pfs, inode, 0, *bank));
    }
    *page = inode->pages[page->inode.page];
    if (page->pageNumber < pfs->inodeStartPage || page->inode.bank >= pfs->banks ||
        page->inode.page <= 0 || page->inode.page >= SDK_PFS_INODE_PAGES) {
        if (page->pageNumber == 1)
            return SDK_PFS_ERR_INVALID;
        return SDK_PFS_ERR_INCONSISTENT;
    }
    return 0;
}

int func_80062DEC(SdkPfs *pfs, int fileNumber, unsigned char flag, int offset,
                  int size, unsigned char *data)
{
    int ret;
    SdkPfsDirectory directory;
    SdkPfsInode inode;
    SdkPfsInodeUnit currentPage;
    int currentBlock;
    int blocks;
    unsigned char *buffer;
    unsigned char bank;
    unsigned short blockNumber;

    if (fileNumber >= pfs->directorySize || fileNumber < 0)
        return SDK_PFS_ERR_INVALID;
    if (size <= 0 || ((size & (SDK_PFS_BLOCK_SIZE - 1)) != 0))
        return SDK_PFS_ERR_INVALID;
    if (offset < 0 || ((offset & (SDK_PFS_BLOCK_SIZE - 1)) != 0))
        return SDK_PFS_ERR_INVALID;
    if ((pfs->status & SDK_PFS_INITIALIZED) == 0)
        return SDK_PFS_ERR_INVALID;
    SDK_PFS_CHECK_ID(pfs);
    if (pfs->activeBank != 0) {
        pfs->activeBank = 0;
        SDK_PFS_ERRCK(func_800695BC(pfs));
    }
    SDK_PFS_ERRCK(func_80069630(pfs->queue, pfs->channel,
                               pfs->directoryTable + fileNumber,
                               (unsigned char *)&directory));
    if (directory.startPage.pageNumber < pfs->inodeStartPage ||
        directory.startPage.inode.bank >= pfs->banks ||
        directory.startPage.inode.page <= 0 ||
        directory.startPage.inode.page >= SDK_PFS_INODE_PAGES) {
        if (directory.startPage.pageNumber == 1)
            return SDK_PFS_ERR_INVALID;
        return SDK_PFS_ERR_INCONSISTENT;
    }
    if (flag == 0 && (directory.status & SDK_PFS_DIR_OCCUPIED) == 0)
        return SDK_PFS_ERR_BAD_DATA;
    bank = -1;
    currentBlock = offset / SDK_PFS_BLOCK_SIZE;
    currentPage = directory.startPage;
    while (currentBlock >= SDK_PFS_BLOCKS_PER_PAGE) {
        SDK_PFS_ERRCK(func_80062CF0(pfs, &bank, &inode, &currentPage));
        currentBlock -= SDK_PFS_BLOCKS_PER_PAGE;
    }
    blocks = size / SDK_PFS_BLOCK_SIZE;
    buffer = data;
    while (blocks > 0) {
        if (currentBlock == SDK_PFS_BLOCKS_PER_PAGE) {
            SDK_PFS_ERRCK(func_80062CF0(pfs, &bank, &inode, &currentPage));
            currentBlock = 0;
        }
        if (pfs->activeBank != currentPage.inode.bank) {
            pfs->activeBank = currentPage.inode.bank;
            SDK_PFS_ERRCK(func_800695BC(pfs));
        }
        blockNumber = currentPage.inode.page * SDK_PFS_BLOCKS_PER_PAGE + currentBlock;
        if (flag == 0)
            ret = func_80069630(pfs->queue, pfs->channel, blockNumber, buffer);
        else
            ret = func_8006A6A0(pfs->queue, pfs->channel, blockNumber, buffer, 0);
        if (ret != 0)
            return ret;
        buffer += SDK_PFS_BLOCK_SIZE;
        currentBlock++;
        blocks--;
    }
    if (flag == 1 && (directory.status & SDK_PFS_DIR_OCCUPIED) == 0) {
        directory.status |= SDK_PFS_DIR_OCCUPIED;
        pfs->activeBank = 0;
        SDK_PFS_ERRCK(func_800695BC(pfs));
        SDK_PFS_ERRCK(func_8006A6A0(pfs->queue, pfs->channel,
                                   pfs->directoryTable + fileNumber,
                                   (unsigned char *)&directory, 0));
    }
    return 0;
}
