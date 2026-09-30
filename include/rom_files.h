#ifndef ROBOTRON_ROM_FILES_H
#define ROBOTRON_ROM_FILES_H

typedef struct RomFileEntry {
    unsigned char unknown0;
    unsigned char name[23];
    unsigned int deviceAddress;
    int size;
} RomFileEntry;

typedef char RomFileEntryMustBe32Bytes[sizeof(RomFileEntry) == 32 ? 1 : -1];

extern RomFileEntry *D_80141200;
extern int D_80141204;

unsigned int func_8004EB80(unsigned int *word);
int func_8004EBC0(short *word);
void func_8004EBE4(void);
void func_8004ED0C(void);
int func_8004ED14(int unused);
int func_8004ED78(unsigned char *name);
void func_8004EE30(void *destination, unsigned int deviceAddress, int count);
int func_8004EE9C(unsigned char *name, void *destination);
int func_8004EF6C(unsigned char *name);

#endif
