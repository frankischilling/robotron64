#include "../../include/sdk_audio.h"

extern int D_8008D798;
extern unsigned int D_8008D834;
extern unsigned int D_801901F0;
extern unsigned int D_801901F4;
extern unsigned int D_801901FC;
extern unsigned char D_8006F440[];
extern unsigned char D_8006F510[];
extern unsigned char D_80071D10[];
extern unsigned char D_80096FD0[];
extern char D_80095C84[];

void func_80052580(void);
unsigned int func_800606A0(void *address);
void func_8005889C(void *message, int arg1, int arg2);

RspTask *func_800521C8(AudioRspRecord *record)
{
    unsigned int remainingBytes;
    unsigned int address;
    SdkAudioCommand *end;
    unsigned int generated;
    RspTask *task;

    func_80052580();
    address = func_800606A0(record->data);
    if (D_8008D7A0 != 0) {
        func_80065B70(D_8008D7A0->data, D_8008D7A0->count * 4);
    }
    remainingBytes = func_80065C20();
    record->count =
        ((D_801901F4 - (remainingBytes >> 2) + D_8008D834) & 0xFFF0) + 0x10;
    if ((unsigned int)record->count < D_801901F0) {
        record->count = D_801901F0;
    }

    end = func_80065D78(D_80190180.commands[D_8008D798], &generated, (short *)address, record->count);
    if (D_801901FC < generated) {
        func_8005889C(D_80095C84, 0, 0);
    }

    record->task.type = 2;
    record->task.flags = 0;
    record->task.ucode_boot = D_8006F440;
    record->task.ucode_boot_size = D_8006F510 - D_8006F440;
    record->task.ucode = D_80071D10;
    record->task.ucode_data = D_80096FD0;
    record->task.ucode_data_size = 0x800;
    record->task.data_ptr = D_80190180.commands[D_8008D798];
    record->task.data_size =
        (((int)end - (int)D_80190180.commands[D_8008D798]) >> 3) << 3;
    record->task.dram_stack = 0;
    record->task.dram_stack_size = 0;
    record->task.output_buff = 0;
    record->task.output_buff_size = 0;
    record->task.yield_data_ptr = 0;
    record->task.yield_data_size = 0;

    task = &record->task;
    return task;
}
