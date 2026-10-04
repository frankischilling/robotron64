#ifndef ROBOTRON_CONTROLLER_SERVICES_H
#define ROBOTRON_CONTROLLER_SERVICES_H

#include "controller_input.h"
#include "sdk_pfs_internal.h"

typedef struct ControllerMotorCommand {
    short operation;
    int port;
} ControllerMotorCommand;

typedef char ControllerMotorCommandMustBe8Bytes[
    sizeof(ControllerMotorCommand) == 8 ? 1 : -1];

extern int D_8008D4E4[4];
extern int D_8008D4F4[4];
extern int D_8008D504;
extern int D_8008D510;
extern unsigned char D_8008D520[];
extern char D_80095BB0[];
extern char D_80095BC8[];
extern unsigned char D_80095BE0[];
extern unsigned char D_8013D9D0;
extern unsigned char D_8013D9D1;
extern SdkPfs D_8013D9D8[4];
extern SdkControllerPad D_8013DBA0[4];
extern OSMesgQueue D_80141210;
extern OSMesgQueue D_80141228;
extern OSMesg D_80141240;
extern OSMesg D_80141244;
extern OSThread D_80141248;
extern unsigned long long D_801413F8[1024];
extern SdkControllerStatus D_801433F8[4];
extern int D_80143408[4];
extern ControllerMotorCommand D_80143418;
extern OSMesg D_80143424;
extern OSMesgQueue D_80143428;
extern SdkPfsState D_80143450[16];
extern int D_80143650[16];
extern unsigned char D_80143690[256];
extern SdkControllerStatus D_80143790[4];

void func_8004EFB0(void);
void func_8004F000(void);
void func_8004F040(void);
void func_8004F06C(void);
void func_8004F178(int port);
void func_8004F1B4(int port);
void func_8004F1EC(void);
void func_8004F4D8(void);
int func_8004F6B4(void);
void func_8004F850(void);
void func_8004F960(int strength);
int func_8004F990(void);
int func_8004F9D4(void);
int func_8004FA14(int slot);
unsigned char *func_8004FAC0(unsigned char *name);
int func_8004FB48(int slot, unsigned int *pages, unsigned char *name);
int func_8004FC98(int retry);

void func_800640D0(int event, OSMesgQueue *queue, OSMesg message);

#endif
