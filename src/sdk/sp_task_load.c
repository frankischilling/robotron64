#include "../../include/sdk_sp_task.h"

void func_8006544C(RspTask *input)
{
    RspTask *task;

    task = func_80065330(input);
    if (task->flags & 1) {
        task->ucode_data = task->yield_data_ptr;
        task->ucode_data_size = task->yield_data_size;
        input->flags &= ~1;
        if (task->flags & 4) {
            task->ucode = *(void **)(((unsigned int)input->yield_data_ptr + 0xBFC)
                                     | 0xA0000000);
        }
    }
    func_80067360(task, sizeof(RspTask));
    func_8006AFF0(0x2B00);
    while (func_8006B320(0x04001000) == -1) {
    }
    while (func_8006B360(1, 0x04000FC0, task, sizeof(RspTask)) == -1) {
    }
    while (func_8006B3F0()) {
    }
    while (func_8006B360(1, 0x04001000, task->ucode_boot, task->ucode_boot_size) == -1) {
    }
}
