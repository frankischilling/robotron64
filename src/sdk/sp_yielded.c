#include "../../include/sdk_rsp.h"

int func_800652B0(RspTask *task)
{
    unsigned int status;
    int yielded;

    status = func_8006B000();
    if (status & 0x100) {
        yielded = 1;
    } else {
        yielded = 0;
    }
    if (status & 0x80) {
        task->flags |= yielded;
        task->flags &= ~2;
    }
    return yielded;
}
