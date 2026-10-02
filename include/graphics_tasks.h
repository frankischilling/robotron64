#ifndef ROBOTRON_GRAPHICS_TASKS_H
#define ROBOTRON_GRAPHICS_TASKS_H

#include "scheduler_task.h"

typedef SchedulerTask GraphicsTask;

extern unsigned long long D_8012E890[128];
extern unsigned long long D_80136CD0[384];

void func_800498E0(int index);
void func_8004FE10(void *arg);
void func_8004FE44(Scheduler *scheduler);
void func_8004FEA8(Scheduler *scheduler);
void func_80050084(void);
void func_80050150(void *arg);
signed short func_80050158(void);
void func_8005018C(GraphicsTask *task, void *data_ptr, unsigned int data_size,
                   unsigned int ucode_index, unsigned int flags);
void func_80050300(void);
void func_80050308(void);

#endif
