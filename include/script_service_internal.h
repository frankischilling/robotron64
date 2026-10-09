#ifndef ROBOTRON_SCRIPT_SERVICE_INTERNAL_H
#define ROBOTRON_SCRIPT_SERVICE_INTERNAL_H

#include "command_script.h"

typedef union ScriptedFileFlags {
    struct {
        signed int registered : 1;
        signed int loaded : 1;
        unsigned int unknown : 30;
    } bits;
    int value;
} ScriptedFileFlags;

typedef struct ScriptedFile {
    ScriptedFileFlags flags;
    int size;
    void *data;
    unsigned char name[14];
    unsigned char path[102];
} ScriptedFile;

typedef char ScriptedFileMustBe128Bytes[sizeof(ScriptedFile) == 0x80 ? 1 : -1];

extern unsigned char D_800904B0[32];
extern unsigned char D_800904D0[64];
extern unsigned char D_80090510[60];
extern unsigned char D_8009054C[56];
extern unsigned char D_80090584[52];
extern unsigned char D_800905B8[64];
extern unsigned char D_800905F8[56];
extern unsigned char D_80090630[48];
extern unsigned char D_80090660[48];

extern ScriptedFile D_80097650[100];
extern ScriptedFile D_8009A850[];

extern CommandScriptEntry D_80077E80[];
extern CommandScriptEntry D_80077EB8[];
extern CommandScriptEntry D_80078040[];
extern CommandScriptEntry D_80078060[];

void func_8001C0D0(char *format, ...);
void func_8001C2C4(unsigned char *format, ...);
void func_8001C49C(unsigned char *format, ...);

void func_8001C740(void);
int func_8001C790(unsigned char *path);
int func_8001C8C4(unsigned char *name);
void *func_8001C968(int handle);
void *func_8001C9FC(int handle);
void func_8001CA78(int handle);
void func_8001CAF4(int handle);

void func_8001CB50(int *command);
void func_8001CBB0(int *command);
void func_8001CBE8(int *command);
void func_8001CC5C(int *command);
void func_8001CCC0(int *command);
void func_8001CCF8(int value);
void func_8001CD00(int value);
void func_8001CD14(void);
void func_8001CD1C(unsigned char *filename);
void func_8001CD60(void);
void func_8001CDA0(int left, int top, int right, int bottom, int value);
void func_8001CE68(void);

#endif
