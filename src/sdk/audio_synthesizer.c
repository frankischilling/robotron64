#include "../../include/sdk_audio_pipeline.h"
#include "../../include/sdk_audio_commands.h"

static int nextSampleTime(AudioSynth *synth, AudioCallbackState **next);
static int timeToSamplesNoRound(AudioSynth *synth, int microseconds);

void func_80066010(AudioSynth *synth, SdkAudioSynthConfig *configuration)
{
    int index;
    SdkAudioVoice *virtualVoice;
    AudioPhysicalVoice *physical;
    SdkAudioVoice *virtualVoices;
    AudioPhysicalVoice *physicalVoices;
    AudioHeap *heap = configuration->heap;
    AudioSaveFilter *save;
    AudioFilter **sources;
    AudioParameter *parameters;
    AudioParameter *parameter;

    synth->head = 0;
    synth->physicalVoiceCount = configuration->maxPhysicalVoices;
    synth->currentSamples = 0;
    synth->parameterSamples = 0;
    synth->outputRate = configuration->outputRate;
    synth->maxOutputSamples = 160;
    synth->dma = configuration->dma;
    save = func_80065730(0, 0, heap, 1, sizeof(AudioSaveFilter));
    func_8006B5E0(save);
    synth->outputFilter = &save->filter;
    synth->auxiliaryBus = func_80065730(0, 0, heap, 1, sizeof(AudioAuxiliaryBus));
    synth->maxAuxiliaryBuses = 1;
    sources = func_80065730(0, 0, heap, configuration->maxPhysicalVoices,
                           sizeof(AudioFilter *));
    func_8006B678(synth->auxiliaryBus, sources, configuration->maxPhysicalVoices);
    synth->mainBus = func_80065730(0, 0, heap, 1, sizeof(AudioBus));
    sources = func_80065730(0, 0, heap, configuration->maxPhysicalVoices,
                           sizeof(AudioFilter *));
    func_8006B624(synth->mainBus, sources, configuration->maxPhysicalVoices);
    if (configuration->effectType != 0) {
        func_8006BD80(synth, 0, configuration, heap);
    } else {
        func_8006BE20(synth->mainBus, 2, synth->auxiliaryBus);
    }
    synth->freeVoices.next = 0;
    synth->freeVoices.previous = 0;
    synth->pendingFreeVoices.next = 0;
    synth->pendingFreeVoices.previous = 0;
    synth->allocatedVoices.next = 0;
    synth->allocatedVoices.previous = 0;
    physicalVoices = func_80065730(0, 0, heap, configuration->maxPhysicalVoices,
                                  sizeof(AudioPhysicalVoice));
    for (index = 0; index < configuration->maxPhysicalVoices; index++) {
        physical = &physicalVoices[index];
        func_80065AE0(&physical->node, &synth->freeVoices);
        physical->voice = 0;
        func_8006B754(&physical->decoder, synth->dma, heap);
        func_8006BF70(&physical->decoder, 1, 0);
        func_8006B6CC(&physical->resampler, heap);
        func_8006CAC0(&physical->resampler, 1, &physical->decoder);
        func_8006B7FC(&physical->envelope, heap);
        func_8006CED4(&physical->envelope, 1, &physical->resampler);
        func_8006DA20(synth->auxiliaryBus, 2, &physical->envelope);
        physical->channel = &physical->envelope.filter;
    }
    func_8006DB30(save, 1, synth->mainBus);
    parameters = func_80065730(0, 0, heap, configuration->maxUpdates,
                              sizeof(AudioParameter));
    synth->parameterList = 0;
    for (index = 0; index < configuration->maxUpdates; index++) {
        parameter = &parameters[index];
        parameter->next = synth->parameterList;
        synth->parameterList = parameter;
    }
    synth->heap = heap;
}

SdkAudioCommand *func_80065D78(SdkAudioCommand *commands, unsigned int *generated,
                               short *outputBuffer, int outputCount)
{
    AudioCallbackState *client;
    AudioFilter *filter;
    AudioSynth *synth = D_8008F160;
    short dmem = 0;
    SdkAudioCommand *nextCommand = commands;
    SdkAudioCommand *current;
    int block;
    short *output = outputBuffer;

    if (synth->head == 0) {
        *generated = 0;
        return commands;
    }
    for (synth->parameterSamples = nextSampleTime(synth, &client);
         synth->parameterSamples - synth->currentSamples < outputCount;
         synth->parameterSamples = nextSampleTime(synth, &client)) {
        synth->parameterSamples &= ~15;
        client->field10 += timeToSamplesNoRound(synth, client->callback(client));
    }
    synth->parameterSamples &= ~15;
    while (outputCount > 0) {
        block = synth->maxOutputSamples < outputCount ? synth->maxOutputSamples : outputCount;
        current = nextCommand;
        SDK_AUDIO_SEGMENT(current++, 0, 0);
        filter = synth->outputFilter;
        filter->setParameter(filter, SDK_AUDIO_SET_DRAM, output);
        nextCommand = filter->handler(filter, &dmem, block, synth->currentSamples,
                                       current);
        outputCount -= block;
        output += block * 2;
        synth->currentSamples += block;
    }
    *generated = nextCommand - commands;
    func_80065CC8(synth);
    return nextCommand;
}

AudioParameter *func_80065D40(void)
{
    AudioSynth *synth = D_8008F160;
    AudioParameter *parameter = 0;

    if (synth->parameterList != 0) {
        parameter = synth->parameterList;
        synth->parameterList = parameter->next;
        parameter->next = 0;
    }
    return parameter;
}

void func_80065D28(AudioParameter *parameter)
{
    AudioSynth *synth = D_8008F160;

    parameter->next = synth->parameterList;
    synth->parameterList = parameter;
}

void func_80065CC8(AudioSynth *synth)
{
    AudioLink *link;

    while ((link = synth->pendingFreeVoices.next) != 0) {
        func_80065AB0(link);
        func_80065AE0(link, &synth->freeVoices);
    }
}

void func_80065C90(AudioSynth *synth, AudioPhysicalVoice *voice)
{
    func_80065AB0(&voice->node);
    func_80065AE0(&voice->node, &synth->pendingFreeVoices);
}

static int timeToSamplesNoRound(AudioSynth *synth, int microseconds)
{
    float samples;

    samples = (float)microseconds * synth->outputRate / 1000000.0 + 0.5;
    return samples;
}

int func_80065C38(AudioSynth *synth, int microseconds)
{
    int samples;

    samples = timeToSamplesNoRound(synth, microseconds);
    return samples & ~15;
}

static int nextSampleTime(AudioSynth *synth, AudioCallbackState **next)
{
    int earliest = 0x7FFFFFFF;
    AudioCallbackState *client;

    *next = 0;
    for (client = synth->head; client != 0; client = client->next) {
        if (client->field10 - synth->currentSamples < earliest) {
            *next = client;
            earliest = client->field10 - synth->currentSamples;
        }
    }
    return (*next)->field10;
}
