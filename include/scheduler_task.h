#ifndef ROBOTRON_SCHEDULER_TASK_H
#define ROBOTRON_SCHEDULER_TASK_H

#include "scheduler.h"

typedef struct RspTask {
    unsigned int type;
    unsigned int flags;
    void *ucode_boot;
    unsigned int ucode_boot_size;
    void *ucode;
    unsigned int ucode_size;
    void *ucode_data;
    unsigned int ucode_data_size;
    void *dram_stack;
    unsigned int dram_stack_size;
    void *output_buff;
    void *output_buff_size;
    void *data_ptr;
    unsigned int data_size;
    void *yield_data_ptr;
    unsigned int yield_data_size;
} RspTask;

/* The producers and dispatchers share this exact target record. */
struct SchedulerTask {
    struct SchedulerTask *next;
    unsigned int state;
    unsigned int flags;
    void *framebuffer;
    RspTask task;
    OSMesgQueue *completionQueue;
    OSMesg completionMessage;
};

typedef char RspTaskMustBe64Bytes[sizeof(RspTask) == 0x40 ? 1 : -1];
typedef char SchedulerTaskMustBe88Bytes[sizeof(SchedulerTask) == 0x58 ? 1 : -1];

#endif
