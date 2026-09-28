#include "../../include/graphics_tasks.h"

typedef unsigned int u32;
typedef signed short s16;

typedef struct GraphicsUcode {
    void *ucode;
    void *ucode_data;
} GraphicsUcode;

typedef struct GraphicsCommand {
    u32 w0;
    u32 w1;
} GraphicsCommand;

#define PACK_SHIFTL(value, shift) ((u32)(value) << (shift))

#define PACK_SET_IMAGE(pkt, cmd, fmt, siz, width, image) \
{ \
    GraphicsCommand *_g = (GraphicsCommand *)(pkt); \
    _g->w0 = PACK_SHIFTL((cmd), 24) | PACK_SHIFTL((fmt), 21) | \
             PACK_SHIFTL((siz), 19) | ((width) - 1); \
    _g->w1 = (u32)(image); \
}

#define PACK_NO_PARAM(pkt, cmd) \
{ \
    GraphicsCommand *_g = (GraphicsCommand *)(pkt); \
    _g->w0 = PACK_SHIFTL((cmd), 24); \
    _g->w1 = 0; \
}

#define PACK_OTHER_MODE(pkt, cmd, shift, length, data) \
{ \
    GraphicsCommand *_g = (GraphicsCommand *)(pkt); \
    _g->w0 = PACK_SHIFTL((cmd), 24) | PACK_SHIFTL((shift), 8) | (length); \
    _g->w1 = (u32)(data); \
}

#define PACK_COLOR(pkt, cmd, data) \
{ \
    GraphicsCommand *_g = (GraphicsCommand *)(pkt); \
    _g->w0 = PACK_SHIFTL((cmd), 24); \
    _g->w1 = (u32)(data); \
}

#define PACK_FILL_RECT(pkt, ulx, uly, lrx, lry) \
{ \
    GraphicsCommand *_g = (GraphicsCommand *)(pkt); \
    _g->w0 = PACK_SHIFTL(0xF6, 24) | PACK_SHIFTL((lrx), 14) | PACK_SHIFTL((lry), 2); \
    _g->w1 = PACK_SHIFTL((ulx), 14) | PACK_SHIFTL((uly), 2); \
}

extern s16 D_80143994, D_80143996;
extern int D_8008D570;
extern u32 D_8014599C;
extern OSMesgQueue D_801437A0;
extern OSMesgQueue *D_80143990;
extern unsigned char D_8006F440[], D_8006F510[];
extern GraphicsUcode D_8008D560[];
extern unsigned char D_8012E890[], D_8012EC90[], D_80136C90[], D_80136CD0[];
extern int D_8007D914;
extern void *D_80138260[];
extern GraphicsCommand *D_80145998;
extern unsigned char D_00200000[];

int func_80062240(OSMesgQueue *, OSMesg *, int);
int func_800635A0(OSMesgQueue *, OSMesg, int);

void func_80050084(void)
{
    int done;
    int seen_two;
    OSMesg msg;

    msg = 0;
    done = 0;
    seen_two = 0;

    while (!done) {
        func_80062240(&D_801437A0, &msg, 1);
        switch (*(s16 *)msg) {
        case 1:
            if (seen_two == 1) {
                done = 1;
            }
            break;
        case 2:
            seen_two = 1;
            break;
        case 3:
            break;
        }
    }
}

void func_80050150(void *arg)
{
}

s16 func_80050158(void)
{
    OSMesg msg = 0;

    func_80062240(&D_801437A0, &msg, 1);
    return *(s16 *)msg;
}

void func_8005018C(GraphicsTask *task, void *data_ptr, u32 data_size, u32 ucode_index, u32 flags)
{
    task->task.data_ptr = data_ptr;
    task->task.data_size = data_size;
    task->task.type = 1;
    task->task.flags = 0;
    task->task.ucode_boot = D_8006F440;
    task->task.ucode_boot_size = D_8006F510 - D_8006F440;
    task->task.ucode = D_8008D560[ucode_index].ucode;
    task->task.ucode_data = D_8008D560[ucode_index].ucode_data;
    task->task.ucode_data_size = 0x800;
    task->task.dram_stack = D_8012E890;
    task->task.dram_stack_size = 0x400;
    task->task.output_buff = D_8012EC90;
    task->task.output_buff_size = D_80136C90;
    task->task.yield_data_ptr = D_80136CD0;
    task->task.yield_data_size = 0xC00;
    task->next = 0;
    task->completionQueue = &D_801437A0;
    task->flags = flags;
    if ((flags & 0x40) != 0) {
        task->completionMessage = &D_80143994;
    } else {
        task->completionMessage = &D_80143996;
    }
    task->framebuffer = D_80138260[D_8007D914];
    func_800635A0(D_80143990, task, 1);
    if ((flags & 0x40) != 0) {
        D_8008D570 ^= 1;
        D_8007D914 ^= 1;
    }
    D_8014599C++;
    D_8014599C &= 7;
}

void func_80050300(void)
{
}

void func_80050308(void)
{
    PACK_SET_IMAGE(D_80145998++, 0xFE, 0, 0, 1, D_00200000);
    PACK_NO_PARAM(D_80145998++, 0xE7);
    PACK_OTHER_MODE(D_80145998++, 0xBA, 20, 2, 0x00300000);
    PACK_SET_IMAGE(D_80145998++, 0xFF, 0, 2, 320, D_00200000);
    PACK_COLOR(D_80145998++, 0xF7, 0xFFFCFFFC);
    PACK_FILL_RECT(D_80145998++, 0, 0, 319, 239);
    PACK_NO_PARAM(D_80145998++, 0xE7);
    PACK_COLOR(D_80145998++, 0xF7, 0x00010001);
    PACK_FILL_RECT(D_80145998++, 0, 0, 319, 239);
    PACK_NO_PARAM(D_80145998++, 0xE7);
}
