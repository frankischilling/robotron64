#include "../../include/sdk_sp_task.h"

RspTask *func_80065330(RspTask *input)
{
    RspTask *task;

    task = &D_801962D0;
    func_8006B010(input, task, sizeof(RspTask));
    if (task->ucode != 0) {
        task->ucode = (void *)func_800606A0(task->ucode);
    }
    if (task->ucode_data != 0) {
        task->ucode_data = (void *)func_800606A0(task->ucode_data);
    }
    if (task->dram_stack != 0) {
        task->dram_stack = (void *)func_800606A0(task->dram_stack);
    }
    if (task->output_buff != 0) {
        task->output_buff = (void *)func_800606A0(task->output_buff);
    }
    if (task->output_buff_size != 0) {
        task->output_buff_size = (void *)func_800606A0(task->output_buff_size);
    }
    if (task->data_ptr != 0) {
        task->data_ptr = (void *)func_800606A0(task->data_ptr);
    }
    if (task->yield_data_ptr != 0) {
        task->yield_data_ptr = (void *)func_800606A0(task->yield_data_ptr);
    }
    return task;
}
