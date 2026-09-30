#ifndef ROBOTRON_CONTROLLER_LEGACY_H
#define ROBOTRON_CONTROLLER_LEGACY_H

#include "controller_services.h"

extern unsigned short D_8013DC08;

void func_8004C090(void);
void func_8004C0B0(void);
void func_8004C0D4(void);
int func_8004C1C8(int port);
unsigned char func_8004C1E0(int port);
int func_800617A0(SdkPfs *pak);

#endif
