#ifndef ROBOTRON_FRAME_H
#define ROBOTRON_FRAME_H

typedef union FrameCommand {
    struct {
        unsigned long w0;
        unsigned long w1;
    } words;
    unsigned long long alignment;
} FrameCommand;

typedef struct FrameView {
    int unknown00[4];
    int angle[3];
    int position[3];
} FrameView;

extern FrameCommand *D_80138254;
extern FrameCommand *D_80138278;
extern FrameView D_800C8BD8;
extern unsigned long long D_80138248;

/* A separate packet scope preserves the command-store order emitted by IDO. */
#define FRAME_COMMAND(first, second) { \
    FrameCommand *command = D_80138254++; \
    command->words.w0 = (first); \
    command->words.w1 = (unsigned int)(second); \
}

void func_80048510(void);
void func_800489F4(void);
void func_80048B8C(void *, int *);
void func_80048BF8(void);
void func_80048D70(void);
void func_80048D90(int);
void func_80048D9C(void);
void func_80049514(void);
int func_800495BC(unsigned long long *);
void func_800496B8(void);
void func_800496D8(void);

#endif
