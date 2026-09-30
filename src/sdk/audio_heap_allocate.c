#include "../../include/audio_runtime.h"

void *func_80065730(unsigned char *file, int line, AudioHeap *heap, int count, int size)
{
    int length;
    unsigned char *result;

    length = (count * size + 15) & ~15;
    result = 0;
    if (heap->current + length <= heap->start + heap->length) {
        result = heap->current;
        heap->current += length;
    }
    return result;
}
