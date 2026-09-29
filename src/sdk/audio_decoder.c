#include "../../include/sdk_audio_decoder.h"

#define AUDIO_FRAME_SAMPLES 16
#define AUDIO_FRAME_BYTES 9
#define AUDIO_LOOP_FLAG 2
#define AUDIO_MIN(left, right) ((left) < (right) ? (left) : (right))

static SdkAudioCommand *decodeChunk(SdkAudioCommand *cursor, AudioLoadFilter *decoder,
                                    int samples, int bytes, short output,
                                    short input, unsigned int flags);

SdkAudioCommand *func_8006C61C(void *state, short *output, int samples,
                               int offset, SdkAudioCommand *commands)
{
    SdkAudioCommand *cursor = commands;
    short input;
    int samplesToDecode;
    int frames;
    int bytes;
    int overflow;
    int startZero;
    int overflowSamples;
    int count;
    int destination;
    int samplesLeft;
    int endOffset;
    int decoded = 0;
    int looped = 0;
    AudioLoadFilter *decoder = state;

    if (samples == 0) {
        return cursor;
    }
    input = SDK_AUDIO_TEMPORARY;
    SDK_AUDIO_LOAD_BOOK(cursor++, decoder->bookSize,
        SDK_AUDIO_PHYSICAL(decoder->table->wave.adpcm.book->coefficients));

    looped = samples + decoder->sample > decoder->loop.end && decoder->loop.count != 0;
    if (looped) {
        count = decoder->loop.end - decoder->sample;
    } else {
        count = samples;
    }
    if (decoder->lastSample) {
        samplesLeft = AUDIO_FRAME_SAMPLES - decoder->lastSample;
    } else {
        samplesLeft = 0;
    }
    samplesToDecode = count - samplesLeft;
    if (samplesToDecode < 0) {
        samplesToDecode = 0;
    }
    frames = (samplesToDecode + AUDIO_FRAME_SAMPLES - 1) >> 4;
    bytes = frames * AUDIO_FRAME_BYTES;

    if (looped) {
        cursor = decodeChunk(cursor, decoder, samplesToDecode, bytes,
                             *output, input, decoder->first);
        if (decoder->lastSample) {
            *output += decoder->lastSample << 1;
        } else {
            *output += AUDIO_FRAME_SAMPLES << 1;
        }

        decoder->lastSample = decoder->loop.start & 15;
        decoder->memoryInput = (int)decoder->table->base +
            AUDIO_FRAME_BYTES * ((int)(decoder->loop.start >> 4) + 1);
        decoder->sample = decoder->loop.start;
        endOffset = *output;

        while (samples > count) {
            samples -= count;
            destination = (endOffset + ((frames + 1) << 5)) & ~31;
            endOffset += count << 1;
            if (decoder->loop.count != -1 && decoder->loop.count != 0) {
                decoder->loop.count--;
            }
            count = AUDIO_MIN(samples, decoder->loop.end - decoder->loop.start);
            samplesToDecode = count - AUDIO_FRAME_SAMPLES + decoder->lastSample;
            if (samplesToDecode < 0) {
                samplesToDecode = 0;
            }
            frames = (samplesToDecode + AUDIO_FRAME_SAMPLES - 1) >> 4;
            bytes = frames * AUDIO_FRAME_BYTES;
            cursor = decodeChunk(cursor, decoder, samplesToDecode, bytes,
                                 destination, input, decoder->first | AUDIO_LOOP_FLAG);
            SDK_AUDIO_DMEM_MOVE(cursor++, destination + (decoder->lastSample << 1),
                                endOffset, count << 1);
        }
        decoder->lastSample = (samples + decoder->lastSample) & 15;
        decoder->sample += samples;
        decoder->memoryInput += AUDIO_FRAME_BYTES * frames;
        return cursor;
    }

    count = frames << 4;
    overflow = decoder->memoryInput + bytes -
        ((int)decoder->table->base + decoder->table->length);
    if (overflow < 0) {
        overflow = 0;
    }
    overflowSamples = (overflow / AUDIO_FRAME_BYTES) << 4;
    if (overflowSamples > count + samplesLeft) {
        overflowSamples = count + samplesLeft;
    }
    bytes -= overflow;
    if (overflowSamples - (overflowSamples & 15) < samples) {
        decoded = 1;
        cursor = decodeChunk(cursor, decoder, count - overflowSamples, bytes,
                             *output, input, decoder->first);
        if (decoder->lastSample) {
            *output += decoder->lastSample << 1;
        } else {
            *output += AUDIO_FRAME_SAMPLES << 1;
        }
        decoder->lastSample = (samples + decoder->lastSample) & 15;
        decoder->sample += samples;
        decoder->memoryInput += AUDIO_FRAME_BYTES * frames;
    } else {
        decoder->lastSample = 0;
        decoder->memoryInput += AUDIO_FRAME_BYTES * frames;
    }
    if (overflowSamples) {
        decoder->lastSample = 0;
        if (decoded) {
            startZero = (samplesLeft + count - overflowSamples) << 1;
        } else {
            startZero = 0;
        }
        SDK_AUDIO_CLEAR(cursor++, startZero + *output, overflowSamples << 1);
    }
    return cursor;
}

SdkAudioCommand *func_8006C144(void *state, short *output, int samples,
                               int offset, SdkAudioCommand *commands)
{
    SdkAudioCommand *cursor = commands;
    int bytes;
    int dramAddress;
    int dramAlignment;
    int dmemAlignment;
    int overflow;
    int startZero;
    int count;
    int destination;
    AudioLoadFilter *decoder = state;

    if (samples == 0) {
        return cursor;
    }
    if (samples + decoder->sample > decoder->loop.end && decoder->loop.count != 0) {
        count = decoder->loop.end - decoder->sample;
        bytes = count << 1;
        if (count > 0) {
            dramAddress = decoder->dma(decoder->memoryInput, bytes, decoder->dmaState);
            dramAlignment = dramAddress & 7;
            bytes += dramAlignment;
            SDK_AUDIO_BUFFER(cursor++, 0, *output, 0, bytes + 8 - (bytes & 7));
            SDK_AUDIO_LOAD(cursor++, dramAddress - dramAlignment);
        } else {
            dramAlignment = 0;
        }
        *output += dramAlignment;
        decoder->memoryInput = (int)decoder->table->base + (decoder->loop.start << 1);
        decoder->sample = decoder->loop.start;
        destination = *output;
        while (samples > count) {
            destination += count << 1;
            samples -= count;
            if (decoder->loop.count != -1 && decoder->loop.count != 0) {
                decoder->loop.count--;
            }
            count = AUDIO_MIN(samples, decoder->loop.end - decoder->loop.start);
            bytes = count << 1;
            dramAddress = decoder->dma(decoder->memoryInput, bytes, decoder->dmaState);
            dramAlignment = dramAddress & 7;
            bytes += dramAlignment;
            if (destination & 7) {
                dmemAlignment = 8 - (destination & 7);
            } else {
                dmemAlignment = 0;
            }
            SDK_AUDIO_BUFFER(cursor++, 0, destination + dmemAlignment, 0,
                              bytes + 8 - (bytes & 7));
            SDK_AUDIO_LOAD(cursor++, dramAddress - dramAlignment);
            if (dramAlignment || dmemAlignment) {
                SDK_AUDIO_DMEM_MOVE(cursor++, destination + dramAlignment + dmemAlignment,
                                    destination, count << 1);
            }
        }
        decoder->sample += samples;
        decoder->memoryInput += samples << 1;
        return cursor;
    }

    bytes = samples << 1;
    overflow = decoder->memoryInput + bytes -
        ((int)decoder->table->base + decoder->table->length);
    if (overflow < 0) {
        overflow = 0;
    }
    if (overflow > bytes) {
        overflow = bytes;
    }
    if (overflow < bytes) {
        if (samples > 0) {
            bytes -= overflow;
            dramAddress = decoder->dma(decoder->memoryInput, bytes, decoder->dmaState);
            dramAlignment = dramAddress & 7;
            bytes += dramAlignment;
            SDK_AUDIO_BUFFER(cursor++, 0, *output, 0, bytes + 8 - (bytes & 7));
            SDK_AUDIO_LOAD(cursor++, dramAddress - dramAlignment);
        } else {
            dramAlignment = 0;
        }
        *output += dramAlignment;
        decoder->sample += samples;
        decoder->memoryInput += samples << 1;
    } else {
        decoder->memoryInput += samples << 1;
    }
    if (overflow) {
        startZero = (samples << 1) - overflow;
        if (startZero < 0) {
            startZero = 0;
        }
        SDK_AUDIO_CLEAR(cursor++, startZero + *output, overflow);
    }
    return cursor;
}

int func_8006BF70(void *state, int parameter, void *value)
{
    AudioLoadFilter *decoder = state;
    AudioFilter *filter = state;

    switch (parameter) {
    case SDK_AUDIO_SET_WAVETABLE:
        decoder->table = value;
        decoder->memoryInput = (int)decoder->table->base;
        decoder->sample = 0;
        switch (decoder->table->type) {
        case SDK_AUDIO_ADPCM_WAVE:
            filter->handler = func_8006C61C;
            decoder->table->length = AUDIO_FRAME_BYTES *
                (int)(decoder->table->length / AUDIO_FRAME_BYTES);
            decoder->bookSize = 2 * decoder->table->wave.adpcm.book->order *
                decoder->table->wave.adpcm.book->predictorCount * 8;
            if (decoder->table->wave.adpcm.loop) {
                decoder->loop.start = decoder->table->wave.adpcm.loop->start;
                decoder->loop.end = decoder->table->wave.adpcm.loop->end;
                decoder->loop.count = decoder->table->wave.adpcm.loop->count;
                func_8006F3C0((unsigned char *)decoder->table->wave.adpcm.loop->state,
                             (unsigned char *)decoder->loopState, sizeof(AudioAdpcmState));
            } else {
                decoder->loop.start = decoder->loop.end = decoder->loop.count = 0;
            }
            break;
        case SDK_AUDIO_RAW16_WAVE:
            filter->handler = func_8006C144;
            if (decoder->table->wave.raw.loop) {
                decoder->loop.start = decoder->table->wave.raw.loop->start;
                decoder->loop.end = decoder->table->wave.raw.loop->end;
                decoder->loop.count = decoder->table->wave.raw.loop->count;
            } else {
                decoder->loop.start = decoder->loop.end = decoder->loop.count = 0;
            }
            break;
        }
        break;
    case SDK_AUDIO_RESET:
        decoder->lastSample = 0;
        decoder->first = 1;
        decoder->sample = 0;
        if (decoder->table) {
            decoder->memoryInput = (int)decoder->table->base;
            if (decoder->table->type == SDK_AUDIO_ADPCM_WAVE) {
                if (decoder->table->wave.adpcm.loop) {
                    decoder->loop.count = decoder->table->wave.adpcm.loop->count;
                }
            } else if (decoder->table->type == SDK_AUDIO_RAW16_WAVE) {
                if (decoder->table->wave.raw.loop) {
                    decoder->loop.count = decoder->table->wave.raw.loop->count;
                }
            }
        }
        break;
    }
}

static SdkAudioCommand *decodeChunk(SdkAudioCommand *cursor, AudioLoadFilter *decoder,
                                    int samples, int bytes, short output,
                                    short input, unsigned int flags)
{
    int dramAlignment;
    int dramAddress;

    if (bytes > 0) {
        dramAddress = decoder->dma(decoder->memoryInput, bytes, decoder->dmaState);
        dramAlignment = dramAddress & 7;
        bytes += dramAlignment;
        SDK_AUDIO_BUFFER(cursor++, 0, input, 0, bytes + 8 - (bytes & 7));
        SDK_AUDIO_LOAD(cursor++, dramAddress - dramAlignment);
    } else {
        dramAlignment = 0;
    }
    if (flags & AUDIO_LOOP_FLAG) {
        SDK_AUDIO_LOOP_STATE(cursor++, SDK_AUDIO_PHYSICAL(decoder->loopState));
    }
    SDK_AUDIO_BUFFER(cursor++, 0, input + dramAlignment, output, samples << 1);
    SDK_AUDIO_DECODE(cursor++, flags, SDK_AUDIO_PHYSICAL(decoder->state));
    decoder->first = 0;
    return cursor;
}
