#ifndef ROBOTRON_EARLY_GAME_HELPERS_H
#define ROBOTRON_EARLY_GAME_HELPERS_H

typedef struct EarlyGamePoolState {
    int unknown00;
    int count;
    int index;
} EarlyGamePoolState;

typedef void (*EarlyRenderHandler)(void *state);

void func_8000A200(int red, int green, int blue);
void func_8000B964(void *state);
void func_8000B99C(void *state);
void func_8000BE80(void *state);
void func_8000BEA0(void *state);
void func_8000BEC0(void *state);
EarlyRenderHandler func_8000CE34(int selection);
void func_8000CF70(int unused);
void func_8000D034(int unused);
void func_8000D054(int unused);
void func_8000D2B4(int unused);
void func_8000D614(int unused, unsigned char *output);
int func_8000DF14(int angle);
int func_80015100(int first, int second, int third, int fourth);
int func_80015118(int first, int second, int third, int fourth);
void func_80015BD4(void *state);
void func_800162F8(void *state);
int func_80016914(int first, int second, int third, int fourth);
int func_80017364(int first, int second, int third, int fourth);
void func_8001B448(void *state, int kind);

#endif
