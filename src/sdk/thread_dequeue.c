#include "../../include/scheduler.h"

void func_800675A0(OSThread **queue, OSThread *thread)
{
    register OSThread **link;
    register OSThread *current;

    link = queue;
    current = *link;
    while (current) {
        if (current == thread) {
            *link = thread->next;
            break;
        }
        link = &current->next;
        current = *link;
    }
}
