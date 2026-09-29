#include "../../include/sdk_pfs_internal.h"

int func_80064140(SdkPfs *pfs, int *bytesNotUsed)
{
    int index;
    int pages;
    SdkPfsInode inode;
    int ret;
    unsigned char bank;
    int offset;

    pages = 0;
    ret = 0;
    if ((pfs->status & SDK_PFS_INITIALIZED) == 0)
        return SDK_PFS_ERR_INVALID;
    SDK_PFS_CHECK_ID(pfs);
    for (bank = 0; bank < pfs->banks; bank++) {
        SDK_PFS_ERRCK(func_8006929C(pfs, &inode, SDK_PFS_READ, bank));
        if (bank > 0)
            offset = 1;
        else
            offset = pfs->inodeStartPage;
        for (index = offset; index < SDK_PFS_INODE_PAGES; index++) {
            if (inode.pages[index].pageNumber == 3)
                pages++;
        }
    }
    *bytesNotUsed = pages * SDK_PFS_BLOCKS_PER_PAGE * SDK_PFS_BLOCK_SIZE;
    return 0;
}
