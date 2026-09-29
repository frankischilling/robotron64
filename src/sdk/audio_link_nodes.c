#include "../../include/sdk_audio.h"

void func_80065AB0(AudioLink *node)
{
    if (node->next != 0) {
        node->next->previous = node->previous;
    }
    if (node->previous != 0) {
        node->previous->next = node->next;
    }
}

void func_80065AE0(AudioLink *node, AudioLink *after)
{
    node->next = after->next;
    node->previous = after;
    if (after->next != 0) {
        after->next->previous = node;
    }
    after->next = node;
}
