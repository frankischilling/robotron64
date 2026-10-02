#ifndef ROBOTRON_RENDERER_IMAGE_SETUP_INTERNAL_H
#define ROBOTRON_RENDERER_IMAGE_SETUP_INTERNAL_H

#include "renderer_draw_state_internal.h"
#include "renderer_geometry_internal.h"

extern int D_8008CB24;
extern int D_8008CB28;
extern int D_8008CB2C;
extern float D_8008CB30;
extern int D_8008CB34;
extern int D_8013D9A0;
extern int D_8013D9A4;
extern int D_8013D9A8;

int func_80047570(RendererDrawState *draw);
void func_8004ACA4(unsigned char *address);
void func_8004AD64(unsigned char *address, int size);
void func_8004AFA4(unsigned char *address);
void func_8004B098(unsigned char *address, int size);

#endif
