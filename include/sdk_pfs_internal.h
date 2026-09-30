#ifndef ROBOTRON_SDK_PFS_INTERNAL_H
#define ROBOTRON_SDK_PFS_INTERNAL_H

#include "sdk_pfs.h"

#define SDK_PFS_ERR_NOPACK 1
#define SDK_PFS_ERR_ID_FATAL 10
#define SDK_PFS_MAX_BANKS 62
#define SDK_PFS_READ 0
#define SDK_PFS_WRITE 1
#define SDK_PFS_PAGE_SHIFT 8

typedef struct SdkPfsPackId {
    unsigned int repaired;
    unsigned int random;
    unsigned long long serialMid;
    unsigned long long serialLow;
    unsigned short deviceId;
    unsigned char banks;
    unsigned char version;
    unsigned short checksum;
    unsigned short invertedChecksum;
} SdkPfsPackId;

typedef struct SdkPfsState {
    unsigned int fileSize;
    unsigned int gameCode;
    unsigned short companyCode;
    char extension[SDK_PFS_EXT_LENGTH];
    char gameName[SDK_PFS_NAME_LENGTH];
} SdkPfsState;

typedef struct SdkPfsInodeCache {
    SdkPfsInode inode;
    unsigned char bank;
    unsigned char map[256];
} SdkPfsInodeCache;

typedef char SdkPfsPackIdMustBe32Bytes[sizeof(SdkPfsPackId) == 32 ? 1 : -1];
typedef char SdkPfsStateMustBe32Bytes[sizeof(SdkPfsState) == 32 ? 1 : -1];
typedef char SdkPfsInodeCacheMustBe514Bytes[sizeof(SdkPfsInodeCache) == 514 ? 1 : -1];

int func_80064290(SdkPfs *, int *, int *);
int func_80061D70(OSMesgQueue *, SdkPfs *, int);
int func_80061A00(OSMesgQueue *, unsigned char *);
int func_800643E0(SdkPfs *, unsigned short, unsigned int, unsigned char *, unsigned char *);
int func_800646C0(SdkPfs *, SdkPfsInode *, unsigned char, unsigned short *, unsigned char,
                  SdkPfsInodeUnit *, int);
int func_800648F8(SdkPfs *, unsigned char, unsigned short *, unsigned char);
int func_800649F0(SdkPfs *, int, SdkPfsState *);

unsigned short func_800688D0(unsigned char *, int);
int func_8006892C(unsigned short *, unsigned short *, unsigned short *);
int func_80068994(SdkPfs *, SdkPfsPackId *, SdkPfsPackId *);
int func_80068DAC(SdkPfs *, SdkPfsPackId *);
int func_80068F44(SdkPfs *);
int func_80069B30(OSMesgQueue *, int);
int func_80069C40(SdkPfs *);
int func_8006A304(SdkPfs *, SdkPfsInodeCache *);
int func_8006A4B8(SdkPfs *, SdkPfsInodeUnit, SdkPfsInodeCache *);
void func_80061BA0(unsigned char);
void func_80061C9C(unsigned char *, SdkControllerStatus *);

unsigned int func_800684C0(void);

#define SDK_PFS_SET_ACTIVE_BANK_ZERO(pfs) \
    if ((pfs)->activeBank != 0) {         \
        (pfs)->activeBank = 0;            \
        SDK_PFS_ERRCK(func_800695BC(pfs)); \
    }

#endif
