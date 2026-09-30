#include "../../include/sdk_pfs_internal.h"

unsigned short func_800688D0(unsigned char *data, int length)
{
    int index;
    unsigned int sum;
    unsigned char *position;

    sum = 0;
    position = data;
    for (index = 0; index < length; index++) {
        sum += *position++;
        sum &= 0xFFFF;
    }
    return sum;
}

int func_8006892C(unsigned short *data, unsigned short *checksum,
                  unsigned short *invertedChecksum)
{
    unsigned short value;
    unsigned int offset;

    value = 0;
    *invertedChecksum = 0;
    *checksum = *invertedChecksum;
    for (offset = 0; offset < 28; offset += 2) {
        value = *(unsigned short *)((unsigned char *)data + offset);
        *checksum += value;
        *invertedChecksum += ~value;
    }
    return 0;
}

int func_80068994(SdkPfs *pfs, SdkPfsPackId *badId, SdkPfsPackId *newId)
{
    int ret;
    unsigned char temp[32];
    unsigned char comparison[32];
    unsigned char mask;
    int index;
    int bank;
    unsigned short idBlocks[4];

    ret = 0;
    mask = 0;
    SDK_PFS_SET_ACTIVE_BANK_ZERO(pfs);
    newId->repaired = -1;
    newId->random = func_800684C0();
    newId->serialMid = badId->serialMid;
    newId->serialLow = badId->serialLow;
    for (bank = 0; bank < SDK_PFS_MAX_BANKS;) {
        pfs->activeBank = bank;
        SDK_PFS_ERRCK(func_800695BC(pfs));
        SDK_PFS_ERRCK(func_80069630(pfs->queue, pfs->channel, 0, temp));
        temp[0] = bank | 0x80;
        for (index = 1; index < 32; index++) {
            temp[index] = ~temp[index];
        }

        SDK_PFS_ERRCK(func_8006A6A0(pfs->queue, pfs->channel, 0, temp, 0));
        SDK_PFS_ERRCK(func_80069630(pfs->queue, pfs->channel, 0, comparison));

        for (index = 0; index < 32; index++) {
            if (comparison[index] != temp[index])
                break;
        }
        if (index != 32)
            break;
        if (bank > 0) {
            pfs->activeBank = 0;
            SDK_PFS_ERRCK(func_800695BC(pfs));
            SDK_PFS_ERRCK(func_80069630(pfs->queue, pfs->channel, 0, temp));
            if (temp[0] != 128)
                break;
        }
        bank++;
    }
    pfs->activeBank = 0;
    SDK_PFS_ERRCK(func_800695BC(pfs));
    if (bank > 0)
        mask = 1;
    else
        mask = 0;
    newId->deviceId = (badId->deviceId & (unsigned short)~1) | mask;
    newId->banks = bank;
    newId->version = badId->version;
    func_8006892C((unsigned short *)newId, &newId->checksum, &newId->invertedChecksum);
    idBlocks[0] = 1;
    idBlocks[1] = 3;
    idBlocks[2] = 4;
    idBlocks[3] = 6;
    for (index = 0; index < 4; index++) {
        SDK_PFS_ERRCK(func_8006A6A0(pfs->queue, pfs->channel, idBlocks[index],
                                   (unsigned char *)newId, 1));
    }
    SDK_PFS_ERRCK(func_80069630(pfs->queue, pfs->channel, 1, temp));
    for (index = 0; index < 32; index++) {
        if (temp[index] != ((unsigned char *)newId)[index])
            return SDK_PFS_ERR_ID_FATAL;
    }
    return 0;
}

int func_80068DAC(SdkPfs *pfs, SdkPfsPackId *id)
{
    unsigned short idBlocks[4];
    int ret;
    unsigned short checksum;
    unsigned short invertedChecksum;
    int index;
    int repairIndex;

    ret = 0;
    SDK_PFS_SET_ACTIVE_BANK_ZERO(pfs);
    idBlocks[0] = 1;
    idBlocks[1] = 3;
    idBlocks[2] = 4;
    idBlocks[3] = 6;
    for (index = 1; index < 4; index++) {
        SDK_PFS_ERRCK(func_80069630(pfs->queue, pfs->channel, idBlocks[index],
                                   (unsigned char *)id));
        func_8006892C((unsigned short *)id, &checksum, &invertedChecksum);
        if (id->checksum == checksum && id->invertedChecksum == invertedChecksum)
            break;
    }
    if (index == 4)
        return SDK_PFS_ERR_ID_FATAL;

    for (repairIndex = 0; repairIndex < 4; repairIndex++) {
        if (repairIndex != index) {
            SDK_PFS_ERRCK(func_8006A6A0(pfs->queue, pfs->channel, idBlocks[repairIndex],
                                       (unsigned char *)id, 1));
        }
    }
    return 0;
}

int func_80068F44(SdkPfs *pfs)
{
    int index;
    unsigned short checksum;
    unsigned short invertedChecksum;
    unsigned char temp[32];
    SdkPfsPackId newId;
    int ret;
    SdkPfsPackId *id;

    SDK_PFS_SET_ACTIVE_BANK_ZERO(pfs);
    SDK_PFS_ERRCK(func_80069630(pfs->queue, pfs->channel, 1, temp));
    func_8006892C((unsigned short *)temp, &checksum, &invertedChecksum);
    id = (SdkPfsPackId *)temp;
    if (id->checksum != checksum || id->invertedChecksum != invertedChecksum) {
        ret = func_80068DAC(pfs, id);
        if (ret == SDK_PFS_ERR_ID_FATAL) {
            SDK_PFS_ERRCK(func_80068994(pfs, id, &newId));
            id = &newId;
        } else if (ret != 0) {
            return ret;
        }
    }
    if ((id->deviceId & 1) == 0) {
        SDK_PFS_ERRCK(func_80068994(pfs, id, &newId));
        id = &newId;
        if ((id->deviceId & 1) == 0)
            return SDK_PFS_ERR_DEVICE;
    }
    for (index = 0; index < 32; index++) {
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
    return 0;
}

int func_800691A0(SdkPfs *pfs)
{
    int index;
    unsigned char temp[32];
    int ret;

    SDK_PFS_SET_ACTIVE_BANK_ZERO(pfs);
    ret = func_80069630(pfs->queue, pfs->channel, 1, temp);
    if (ret != 0) {
        if (ret != SDK_PFS_ERR_NEW_PACK)
            return ret;
        else
            SDK_PFS_ERRCK(func_80069630(pfs->queue, pfs->channel, 1, temp));
    }

    for (index = 0; index < 32; index++) {
        if (pfs->id[index] != temp[index])
            return SDK_PFS_ERR_NEW_PACK;
    }

    return 0;
}

int func_8006929C(SdkPfs *pfs, SdkPfsInode *inode, unsigned char flag,
                  unsigned char bank)
{
    unsigned char sum;
    int index;
    int ret;
    int offset;
    unsigned char *address;

    SDK_PFS_SET_ACTIVE_BANK_ZERO(pfs);

    if (bank > 0)
        offset = 1;
    else
        offset = pfs->inodeStartPage;

    if (flag == SDK_PFS_WRITE)
        inode->pages[0].inode.page = func_800688D0((unsigned char *)&inode->pages[offset],
                                                   (-offset) * 2 + 256);

    for (index = 0; index < 8; index++) {
        address = (unsigned char *)inode->pages + index * 32;
        if (flag == SDK_PFS_WRITE) {
            ret = func_8006A6A0(pfs->queue, pfs->channel,
                                pfs->inodeTable + bank * 8 + index, address, 0);
            ret = func_8006A6A0(pfs->queue, pfs->channel,
                                pfs->mirrorInodeTable + bank * 8 + index, address, 0);
        } else {
            ret = func_80069630(pfs->queue, pfs->channel,
                                pfs->inodeTable + bank * 8 + index, address);
        }
        if (ret != 0)
            return ret;
    }
    if (flag == SDK_PFS_READ) {
        sum = func_800688D0((unsigned char *)&inode->pages[offset], (-offset) * 2 + 256);
        if (sum != inode->pages[0].inode.page) {
            for (index = 0; index < SDK_PFS_BLOCKS_PER_PAGE; index++) {
                address = (unsigned char *)inode->pages + index * 32;
                ret = func_80069630(pfs->queue, pfs->channel,
                                    pfs->mirrorInodeTable + bank * SDK_PFS_BLOCKS_PER_PAGE + index,
                                    address);
            }
            if (sum != inode->pages[0].inode.page)
                return SDK_PFS_ERR_INCONSISTENT;
            for (index = 0; index < SDK_PFS_BLOCKS_PER_PAGE; index++) {
                address = (unsigned char *)inode->pages + index * 32;
                ret = func_8006A6A0(pfs->queue, pfs->channel,
                                    pfs->inodeTable + bank * SDK_PFS_BLOCKS_PER_PAGE + index,
                                    address, 0);
            }
        } else {
            for (index = 0; index < SDK_PFS_BLOCKS_PER_PAGE; index++) {
                address = (unsigned char *)inode->pages + index * 32;
                ret = func_8006A6A0(pfs->queue, pfs->channel,
                                    pfs->mirrorInodeTable + bank * SDK_PFS_BLOCKS_PER_PAGE + index,
                                    address, 0);
            }
        }
    }
    return 0;
}

int func_800695BC(SdkPfs *pfs)
{
    unsigned char temp[SDK_PFS_BLOCK_SIZE];
    int index;
    int ret;

    ret = 0;
    for (index = 0; index < SDK_PFS_BLOCK_SIZE; index++) {
        temp[index] = pfs->activeBank;
    }
    ret = func_8006A6A0(pfs->queue, pfs->channel, 1024, temp, 0);
    return ret;
}
