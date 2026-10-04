#ifndef ROBOTRON_CONTROLLER_PAK_MENU_INTERNAL_H
#define ROBOTRON_CONTROLLER_PAK_MENU_INTERNAL_H

#define PAK_MENU_FILE_COUNT 16

/* The directory loop advances each label by 30 bytes. */
typedef struct PakMenuFileName {
    unsigned char name[30];
} PakMenuFileName;

typedef char PakMenuFileNameMustBe30Bytes[
    sizeof(PakMenuFileName) == 30 ? 1 : -1];

extern int D_80077A94;
/* This is the measured span before the labels; the original declaration is unknown. */
extern unsigned char D_800BAEA0[104];
extern PakMenuFileName D_800BAF08[PAK_MENU_FILE_COUNT];
extern PakMenuFileName *D_800BB0E8[PAK_MENU_FILE_COUNT];

extern unsigned char D_80093838[24];
extern unsigned char D_80093850[32];
extern unsigned char D_80093870[8];
extern unsigned char D_80093878[4];
extern unsigned char D_8009387C[32];
extern unsigned char D_8009389C[44];

void func_800266BC(int *selection);

#endif
