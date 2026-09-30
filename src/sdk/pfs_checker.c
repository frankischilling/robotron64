#include "../../include/sdk_pfs_internal.h"

#define SDK_PFS_CORRUPTED 2

int func_80069C40(SdkPfs *pfs)
{
    int index;
    int ret;
    SdkPfsInodeUnit nextPage;
    SdkPfsInode checkedInode;
    SdkPfsInode tempInode;
    SdkPfsDirectory directory;
    SdkPfsInodeUnit fileNextNode[16];
    SdkPfsInodeCache cache;
    int fixed;
    unsigned char bank;
    int corruptionCount;
    int previousLink;
    int offset;

    fixed = 0;
    ret = func_800691A0(pfs);
    if (ret == SDK_PFS_ERR_NEW_PACK)
        ret = func_80068F44(pfs);
    if (ret != 0)
        return ret;
    SDK_PFS_ERRCK(func_8006A304(pfs, &cache));
    for (index = 0; index < pfs->directorySize; index++) {
        SDK_PFS_ERRCK(func_80069630(pfs->queue, pfs->channel,
                                   pfs->directoryTable + index,
                                   (unsigned char *)&directory));
        if (directory.companyCode != 0 && directory.gameCode != 0) {
            nextPage = directory.startPage;
            corruptionCount = 0;
            previousLink = 0;
            bank = 255;
            while (nextPage.pageNumber >= pfs->inodeStartPage &&
                   nextPage.inode.bank < pfs->banks && nextPage.inode.page > 0 &&
                   nextPage.inode.page < SDK_PFS_INODE_PAGES) {
                if (bank != nextPage.inode.bank) {
                    bank = nextPage.inode.bank;
                    ret = func_8006929C(pfs, &tempInode, SDK_PFS_READ, bank);
                    if (ret != 0 && ret != SDK_PFS_ERR_INCONSISTENT)
                        return ret;
                }
                corruptionCount = func_8006A4B8(pfs, nextPage, &cache) - previousLink;
                if (corruptionCount != 0)
                    break;
                previousLink = 1;
                nextPage = tempInode.pages[nextPage.inode.page];
            }
            if (corruptionCount == 0 && nextPage.pageNumber == 1)
                continue;

            directory.companyCode = 0;
            directory.gameCode = 0;
            directory.startPage.pageNumber = 0;
            directory.status = 0;
            directory.dataSum = 0;
            SDK_PFS_SET_ACTIVE_BANK_ZERO(pfs);
            SDK_PFS_ERRCK(func_8006A6A0(pfs->queue, pfs->channel,
                                       pfs->directoryTable + index,
                                       (unsigned char *)&directory, 0));
            fixed++;
        } else {
            if (directory.companyCode == 0 && directory.gameCode == 0)
                continue;
            directory.companyCode = 0;
            directory.gameCode = 0;
            directory.startPage.pageNumber = 0;
            directory.status = 0;
            directory.dataSum = 0;

            SDK_PFS_SET_ACTIVE_BANK_ZERO(pfs);
            SDK_PFS_ERRCK(func_8006A6A0(pfs->queue, pfs->channel,
                                       pfs->directoryTable + index,
                                       (unsigned char *)&directory, 0));
            fixed++;
        }
    }
    for (index = 0; index < pfs->directorySize; index++) {
        SDK_PFS_ERRCK(func_80069630(pfs->queue, pfs->channel,
                                   pfs->directoryTable + index,
                                   (unsigned char *)&directory));

        if (directory.companyCode != 0 && directory.gameCode != 0 &&
            directory.startPage.pageNumber >= (unsigned short)pfs->inodeStartPage) {
            fileNextNode[index].pageNumber = directory.startPage.pageNumber;
        } else {
            fileNextNode[index].pageNumber = 0;
        }
    }
    for (bank = 0; bank < pfs->banks; bank++) {
        ret = func_8006929C(pfs, &tempInode, SDK_PFS_READ, bank);
        if (ret != 0 && ret != SDK_PFS_ERR_INCONSISTENT)
            return ret;
        if (bank > 0)
            offset = 1;
        else
            offset = pfs->inodeStartPage;
        for (index = 0; index < offset; index++) {
            checkedInode.pages[index].pageNumber = tempInode.pages[index].pageNumber;
        }
        for (; index < SDK_PFS_INODE_PAGES; index++) {
            checkedInode.pages[index].pageNumber = 3;
        }
        for (index = 0; index < pfs->directorySize; index++) {
            while (fileNextNode[index].inode.bank == bank &&
                   fileNextNode[index].pageNumber >= (unsigned short)pfs->inodeStartPage) {
                unsigned char page = fileNextNode[index].inode.page;
                fileNextNode[index] = checkedInode.pages[page] = tempInode.pages[page];
            }
        }
        SDK_PFS_ERRCK(func_8006929C(pfs, &checkedInode, SDK_PFS_WRITE, bank));
    }
    if (fixed)
        pfs->status |= SDK_PFS_CORRUPTED;
    else
        pfs->status &= ~SDK_PFS_CORRUPTED;

    return 0;
}

int func_8006A304(SdkPfs *pfs, SdkPfsInodeCache *cache)
{
    int index;
    int mapIndex;
    int offset;
    unsigned char bank;
    SdkPfsInodeUnit page;
    SdkPfsInode tempInode;
    int ret;

    for (index = 0; index < 256; index++)
        cache->map[index] = 0;
    cache->bank = -1;
    for (bank = 0; bank < pfs->banks; bank++) {
        if (bank > 0)
            offset = 1;
        else
            offset = pfs->inodeStartPage;

        ret = func_8006929C(pfs, &tempInode, SDK_PFS_READ, bank);
        if (ret != 0 && ret != SDK_PFS_ERR_INCONSISTENT)
            return ret;
        for (index = offset; index < SDK_PFS_INODE_PAGES; index++) {
            page = tempInode.pages[index];
            if (page.pageNumber >= pfs->inodeStartPage && page.inode.bank != bank) {
                mapIndex = (page.inode.page / 4) +
                           ((page.inode.bank % SDK_PFS_BLOCKS_PER_PAGE) * SDK_PFS_BLOCK_SIZE);
                cache->map[mapIndex] |= 1 << (bank % SDK_PFS_BLOCKS_PER_PAGE);
            }
        }
    }
    return 0;
}

int func_8006A4B8(SdkPfs *pfs, SdkPfsInodeUnit filePage, SdkPfsInodeCache *cache)
{
    int index;
    int mapIndex;
    int hits;
    unsigned char bank;
    int offset;
    int ret;

    hits = 0;
    ret = 0;
    mapIndex = (filePage.inode.page / 4) +
               (filePage.inode.bank % SDK_PFS_BLOCKS_PER_PAGE) * SDK_PFS_BLOCK_SIZE;
    for (bank = 0; bank < pfs->banks; bank++) {
        if (bank > 0)
            offset = 1;
        else
            offset = pfs->inodeStartPage;
        if (bank == filePage.inode.bank ||
            cache->map[mapIndex] & (1 << (bank % SDK_PFS_BLOCKS_PER_PAGE))) {
            if (bank != cache->bank) {
                ret = func_8006929C(pfs, &cache->inode, SDK_PFS_READ, bank);
                if (ret != 0 && ret != SDK_PFS_ERR_INCONSISTENT)
                    return ret;
                cache->bank = bank;
            }

            for (index = offset; hits < 2 && index < SDK_PFS_INODE_PAGES; index++) {
                if (cache->inode.pages[index].pageNumber == filePage.pageNumber)
                    hits++;
            }
            if (1 < hits)
                return SDK_PFS_ERR_NEW_PACK;
        }
    }
    return hits;
}
