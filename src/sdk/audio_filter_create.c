#include "../../include/sdk_audio_pipeline.h"

void func_8006B7FC(AudioEnvelopeMixer *filter, AudioHeap *heap)
{
    func_8006E750(&filter->filter, func_8006D4CC, func_8006CED4, 4);
    filter->state = func_80065730(0, 0, heap, 1, sizeof(AudioEnvelopeState));
    filter->first = 1;
    filter->motion = 0;
    filter->volume = 1;
    filter->leftTarget = 1;
    filter->rightTarget = 1;
    filter->currentLeft = 1;
    filter->currentRight = 1;
    filter->dryAmount = 0;
    filter->wetAmount = 0;
    filter->leftRateHigh = 1;
    filter->leftRateLow = 0;
    filter->delta = 0;
    filter->segmentEnd = 0;
    filter->pan = 0;
    filter->controlList = 0;
    filter->controlTail = 0;
    filter->sources = 0;
}

void func_8006B754(AudioLoadFilter *filter, AudioDmaFactory factory, AudioHeap *heap)
{
    func_8006E750(&filter->filter, func_8006C61C, func_8006BF70, 0);
    filter->state = func_80065730(0, 0, heap, 1, sizeof(AudioAdpcmState));
    filter->loopState = func_80065730(0, 0, heap, 1, sizeof(AudioAdpcmState));
    filter->dma = factory(&filter->dmaState);
    filter->lastSample = 0;
    filter->first = 1;
    filter->memoryInput = 0;
}

void func_8006B6CC(AudioResampler *filter, AudioHeap *heap)
{
    func_8006E750(&filter->filter, func_8006CBAC, func_8006CAC0, 1);
    filter->state = func_80065730(0, 0, heap, 1, sizeof(AudioResampleState));
    filter->first = 1;
    filter->motion = 0;
    filter->unityPitch = 0;
    filter->controlList = 0;
    filter->controlTail = 0;
    filter->delta = 0.0f;
    filter->ratio = 1.0f;
}

void func_8006B678(AudioAuxiliaryBus *bus, void *sources, int maxSources)
{
    func_8006E750(&bus->bus.filter, func_8006DA50, func_8006DA20, 6);
    bus->bus.sourceCount = 0;
    bus->bus.maxSources = maxSources;
    bus->bus.sources = sources;
}

void func_8006B624(AudioBus *bus, void *sources, int maxSources)
{
    func_8006E750(&bus->filter, func_8006BE50, func_8006BE20, 7);
    bus->sourceCount = 0;
    bus->maxSources = maxSources;
    bus->sources = sources;
}

void func_8006B5E0(AudioSaveFilter *filter)
{
    func_8006E750(&filter->filter, func_8006DB64, func_8006DB30, 3);
    filter->dramOutput = 0;
    filter->first = 1;
}
