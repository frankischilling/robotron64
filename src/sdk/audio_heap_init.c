#include "../../include/audio_runtime.h"

void func_800656F0(AudioHeap *heap, void *start, int length)
{
    int alignment;

    alignment = 16 - ((int)start & 15);
    if (alignment != 16) {
        heap->start = (unsigned char *)start + alignment;
    } else {
        heap->start = start;
    }
    heap->length = length;
    heap->current = heap->start;
    heap->count = 0;
}
