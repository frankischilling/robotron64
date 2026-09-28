#ifndef ROBOTRON_SDK_PFS_H
#define ROBOTRON_SDK_PFS_H

#include "sdk_controller.h"

#define SDK_PFS_BLOCK_SIZE 32
#define SDK_PFS_BLOCKS_PER_PAGE 8
#define SDK_PFS_INODE_PAGES 128
#define SDK_PFS_NAME_LENGTH 16
#define SDK_PFS_EXT_LENGTH 4

#define SDK_PFS_INITIALIZED 1
#define SDK_PFS_DIR_OCCUPIED 2

#define SDK_PFS_ERR_NEW_PACK 2
#define SDK_PFS_ERR_INCONSISTENT 3
#define SDK_PFS_ERR_CONTRFAIL 4
#define SDK_PFS_ERR_INVALID 5
#define SDK_PFS_ERR_BAD_DATA 6
#define SDK_PFS_DATA_FULL 7
#define SDK_PFS_DIR_FULL 8
#define SDK_PFS_ERR_EXIST 9
#define SDK_PFS_ERR_DEVICE 11

typedef union SdkPfsInodeUnit {
    struct {
        unsigned char bank;
        unsigned char page;
    } inode;
    unsigned short pageNumber;
} SdkPfsInodeUnit;

typedef struct SdkPfsInode {
    SdkPfsInodeUnit pages[SDK_PFS_INODE_PAGES];
} SdkPfsInode;

typedef struct SdkPfsDirectory {
    unsigned int gameCode;
    unsigned short companyCode;
    SdkPfsInodeUnit startPage;
    unsigned char status;
    signed char reserved;
    unsigned short dataSum;
    unsigned char extension[SDK_PFS_EXT_LENGTH];
    unsigned char gameName[SDK_PFS_NAME_LENGTH];
} SdkPfsDirectory;

typedef struct SdkPfs {
    int status;
    OSMesgQueue *queue;
    int channel;
    unsigned char id[32];
    unsigned char label[32];
    int version;
    int directorySize;
    int inodeTable;
    int mirrorInodeTable;
    int directoryTable;
    int inodeStartPage;
    unsigned char banks;
    unsigned char activeBank;
} SdkPfs;

typedef struct SdkContRamPacket {
    unsigned char dummy;
    unsigned char transmitLength;
    unsigned char receiveLength;
    unsigned char command;
    unsigned short address;
    unsigned char data[SDK_PFS_BLOCK_SIZE];
    unsigned char dataCrc;
} SdkContRamPacket;

typedef char SdkPfsInodeUnitMustBe2Bytes[sizeof(SdkPfsInodeUnit) == 2 ? 1 : -1];
typedef char SdkPfsInodeMustBe256Bytes[sizeof(SdkPfsInode) == 256 ? 1 : -1];
typedef char SdkPfsDirectoryMustBe32Bytes[sizeof(SdkPfsDirectory) == 32 ? 1 : -1];
typedef char SdkPfsMustBe104Bytes[sizeof(SdkPfs) == 104 ? 1 : -1];
typedef char SdkContRamPacketMustBe40Bytes[sizeof(SdkContRamPacket) == 40 ? 1 : -1];

extern SdkPifRam D_80194D20;
extern SdkPifRam D_80194D60[4];
extern SdkPifRam D_80194E60[4];
extern unsigned char D_80194F60[32];
extern unsigned char D_80194F80[32];

int func_80062380(SdkPfs *, unsigned short, unsigned int, unsigned char *, unsigned char *, int *);
int func_80062540(SdkPfs *, unsigned short, unsigned int, unsigned char *, unsigned char *, int, int *);
int func_800629C4(SdkPfs *, SdkPfsInode *, int, int *, unsigned char, int *, int *);
int func_80062C28(SdkPfs *, int, unsigned char *, unsigned char);
int func_80062DEC(SdkPfs *, int, unsigned char, int, int, unsigned char *);
int func_800636F0(SdkPfs *);
int func_80063858(SdkPfs *);
void func_800639C4(int, unsigned short, unsigned char *, SdkPifRam *);
int func_80063B40(OSMesgQueue *, SdkPfs *, int);

int func_80064140(SdkPfs *, int *);
int func_800691A0(SdkPfs *);
int func_8006929C(SdkPfs *, SdkPfsInode *, unsigned char, unsigned char);
int func_800695BC(SdkPfs *);
int func_80069630(OSMesgQueue *, int, unsigned short, unsigned char *);
int func_8006A6A0(OSMesgQueue *, int, unsigned short, unsigned char *, int);

#define SDK_PFS_ERRCK(call) \
    ret = (call);            \
    if (ret != 0)            \
        return ret

#define SDK_PFS_CHECK_ID(pfs)                         \
    if (func_800691A0((pfs)) == SDK_PFS_ERR_NEW_PACK) \
        return SDK_PFS_ERR_NEW_PACK

#endif
