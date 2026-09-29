#include "../../include/sdk_audio_envelope.h"

#define AUDIO_EQUAL_POWER_COUNT 128

static short equalPower[AUDIO_EQUAL_POWER_COUNT] = {
    32767, 32764, 32757, 32744, 32727, 32704,
    32677, 32644, 32607, 32564, 32517, 32464,
    32407, 32344, 32277, 32205, 32127, 32045,
    31958, 31866, 31770, 31668, 31561, 31450,
    31334, 31213, 31087, 30957, 30822, 30682,
    30537, 30388, 30234, 30075, 29912, 29744,
    29572, 29395, 29214, 29028, 28838, 28643,
    28444, 28241, 28033, 27821, 27605, 27385,
    27160, 26931, 26698, 26461, 26220, 25975,
    25726, 25473, 25216, 24956, 24691, 24423,
    24151, 23875, 23596, 23313, 23026, 22736,
    22442, 22145, 21845, 21541, 21234, 20924,
    20610, 20294, 19974, 19651, 19325, 18997,
    18665, 18331, 17993, 17653, 17310, 16965,
    16617, 16266, 15913, 15558, 15200, 14840,
    14477, 14113, 13746, 13377, 13006, 12633,
    12258, 11881, 11503, 11122, 10740, 10357,
    9971, 9584, 9196, 8806, 8415, 8023,
    7630, 7235, 6839, 6442, 6044, 5646,
    5246, 4845, 4444, 4042, 3640, 3237,
    2833, 2429, 2025, 1620, 1216, 810,
    405, 0
};

static SdkAudioCommand *pullSubFrame(void *state, short *input, short *output,
                                     int samples, int offset, SdkAudioCommand *commands);
static short getRate(double volume, double target, int samples, unsigned short *low);
static float getVolume(float initial, int samples, short high, unsigned short low);

SdkAudioCommand *func_8006D4CC(void *state, short *output, int samples,
                               int offset, SdkAudioCommand *commands)
{
    SdkAudioCommand *cursor = commands;
    AudioEnvelopeMixer *envelope = state;
    short input;
    int previousOffset;
    int currentOffset = offset;
    int count;
    short outputOffset = 0;
    int volume;
    AudioParameter *parameter;

    input = SDK_AUDIO_TEMPORARY;
    while (envelope->controlList != 0) {
        previousOffset = currentOffset;
        currentOffset = envelope->controlList->delta;
        count = currentOffset - previousOffset;
        if (count > samples) {
            break;
        }
        switch (envelope->controlList->type) {
        case SDK_AUDIO_START_VOICE_PARAMETERS:
            {
                AudioStartParameter *start = (AudioStartParameter *)envelope->controlList;
                AudioFilter *filter = (AudioFilter *)envelope;
                int squaredVolume;

                if (start->unity) {
                    envelope->filter.setParameter(&envelope->filter, SDK_AUDIO_SET_UNITY_PITCH, 0);
                }
                envelope->filter.setParameter(&envelope->filter, SDK_AUDIO_SET_WAVETABLE, start->wave);
                envelope->filter.setParameter(&envelope->filter, SDK_AUDIO_START, 0);
                envelope->first = 1;
                envelope->delta = 0;
                envelope->segmentEnd = start->samples;
                squaredVolume = ((int)start->volume * (int)start->volume) >> 15;
                envelope->volume = (short)squaredVolume;
                envelope->pan = start->pan;
                envelope->dryAmount = equalPower[start->effectMix];
                envelope->wetAmount = equalPower[AUDIO_EQUAL_POWER_COUNT - start->effectMix - 1];
                if (start->samples) {
                    envelope->currentLeft = 1;
                    envelope->currentRight = 1;
                } else {
                    envelope->currentLeft = (envelope->volume * equalPower[envelope->pan]) >> 15;
                    envelope->currentRight = (envelope->volume *
                        equalPower[AUDIO_EQUAL_POWER_COUNT - envelope->pan - 1]) >> 15;
                }
                if (filter->source) {
                    union {
                        float floating;
                        int integer;
                    } pitch;
                    pitch.floating = start->pitch;
                    filter->source->setParameter(filter->source, SDK_AUDIO_SET_PITCH,
                                                 (void *)pitch.integer);
                }
            }
            break;
        case SDK_AUDIO_SET_EFFECT_AMOUNT:
        case SDK_AUDIO_SET_PAN:
        case SDK_AUDIO_SET_VOLUME:
            cursor = pullSubFrame(envelope, &input, &outputOffset, count, offset, cursor);
            if (envelope->delta >= envelope->segmentEnd) {
                envelope->leftTarget = (envelope->volume * equalPower[envelope->pan]) >> 15;
                envelope->rightTarget = (envelope->volume *
                    equalPower[AUDIO_EQUAL_POWER_COUNT - envelope->pan - 1]) >> 15;
                envelope->delta = envelope->segmentEnd;
                envelope->currentLeft = envelope->leftTarget;
                envelope->currentRight = envelope->rightTarget;
            } else {
                envelope->currentLeft = getVolume(envelope->currentLeft, envelope->delta,
                    envelope->leftRateHigh, envelope->leftRateLow);
                envelope->currentRight = getVolume(envelope->currentRight, envelope->delta,
                    envelope->rightRateHigh, envelope->rightRateLow);
            }
            if (envelope->currentLeft == 0) {
                envelope->currentLeft = 1;
            }
            if (envelope->currentRight == 0) {
                envelope->currentRight = 1;
            }
            if (envelope->controlList->type == SDK_AUDIO_SET_PAN) {
                envelope->pan = (short)envelope->controlList->data.integer;
            }
            if (envelope->controlList->type == SDK_AUDIO_SET_VOLUME) {
                envelope->delta = 0;
                volume = envelope->controlList->data.integer;
                volume = (volume * volume) >> 15;
                envelope->volume = (short)volume;
                envelope->segmentEnd = envelope->controlList->more.integer;
            }
            if (envelope->controlList->type == SDK_AUDIO_SET_EFFECT_AMOUNT) {
                envelope->dryAmount = equalPower[envelope->controlList->data.integer];
                envelope->wetAmount = equalPower[AUDIO_EQUAL_POWER_COUNT -
                    envelope->controlList->data.integer - 1];
            }
            envelope->first = 1;
            break;
        case SDK_AUDIO_START_VOICE:
            {
                AudioSimpleStartParameter *start =
                    (AudioSimpleStartParameter *)envelope->controlList;
                if (start->unity) {
                    envelope->filter.setParameter(&envelope->filter, SDK_AUDIO_SET_UNITY_PITCH, 0);
                }
                envelope->filter.setParameter(&envelope->filter, SDK_AUDIO_SET_WAVETABLE, start->wave);
                envelope->filter.setParameter(&envelope->filter, SDK_AUDIO_START, 0);
            }
            break;
        case SDK_AUDIO_STOP_VOICE:
            cursor = pullSubFrame(envelope, &input, &outputOffset, count, offset, cursor);
            envelope->filter.setParameter(&envelope->filter, SDK_AUDIO_RESET, 0);
            break;
        case SDK_AUDIO_FREE_VOICE:
            {
                AudioSynth *synth = D_8008F160;
                AudioFreeParameter *release = (AudioFreeParameter *)envelope->controlList;
                release->physical->offset = 0;
                func_80065C90(synth, release->physical);
            }
            break;
        default:
            cursor = pullSubFrame(envelope, &input, &outputOffset, count, offset, cursor);
            envelope->filter.setParameter(&envelope->filter, envelope->controlList->type,
                                           (void *)envelope->controlList->data.integer);
            break;
        }
        outputOffset += count << 1;
        samples -= count;
        parameter = envelope->controlList;
        envelope->controlList = envelope->controlList->next;
        if (envelope->controlList == 0) {
            envelope->controlTail = 0;
        }
        func_80065D28(parameter);
    }
    cursor = pullSubFrame(envelope, &input, &outputOffset, samples, offset, cursor);
    if (envelope->delta > envelope->segmentEnd) {
        envelope->delta = envelope->segmentEnd;
    }
    return cursor;
}

int func_8006CED4(void *state, int parameter, void *value)
{
    AudioFilter *filter = state;
    AudioEnvelopeMixer *envelope = state;

    switch (parameter) {
    case SDK_AUDIO_ADD_UPDATE:
        if (envelope->controlTail) {
            envelope->controlTail->next = value;
        } else {
            envelope->controlList = value;
        }
        envelope->controlTail = value;
        break;
    case SDK_AUDIO_RESET:
        envelope->first = 1;
        envelope->motion = 0;
        envelope->volume = 1;
        if (filter->source) {
            filter->source->setParameter(filter->source, SDK_AUDIO_RESET, value);
        }
        break;
    case SDK_AUDIO_START:
        envelope->motion = 1;
        if (filter->source) {
            filter->source->setParameter(filter->source, SDK_AUDIO_START, value);
        }
        break;
    case SDK_AUDIO_SET_SOURCE:
        filter->source = value;
        break;
    default:
        if (filter->source) {
            filter->source->setParameter(filter->source, parameter, value);
        }
    }
    return 0;
}

static SdkAudioCommand *pullSubFrame(void *state, short *input, short *output,
                                     int samples, int offset, SdkAudioCommand *commands)
{
    SdkAudioCommand *cursor = commands;
    AudioEnvelopeMixer *envelope = state;
    AudioFilter *source = envelope->filter.source;

    if (envelope->motion != 1 || !samples) {
        return cursor;
    }
    cursor = source->handler(source, input, samples, offset, commands);
    SDK_AUDIO_BUFFER(cursor++, 0, *input, SDK_AUDIO_MAIN_LEFT + *output, samples << 1);
    SDK_AUDIO_BUFFER(cursor++, SDK_AUDIO_ENVELOPE_AUXILIARY,
        SDK_AUDIO_MAIN_RIGHT + *output, SDK_AUDIO_AUX_LEFT + *output, SDK_AUDIO_AUX_RIGHT + *output);
    if (envelope->first) {
        envelope->first = 0;
        envelope->leftTarget = (envelope->volume * equalPower[envelope->pan]) >> 15;
        envelope->leftRateHigh = getRate((double)envelope->currentLeft,
            (double)envelope->leftTarget, envelope->segmentEnd, &envelope->leftRateLow);
        envelope->rightTarget = (envelope->volume *
            equalPower[AUDIO_EQUAL_POWER_COUNT - envelope->pan - 1]) >> 15;
        envelope->rightRateHigh = getRate((double)envelope->currentRight,
            (double)envelope->rightTarget, envelope->segmentEnd, &envelope->rightRateLow);
        SDK_AUDIO_VOLUME(cursor++, SDK_AUDIO_ENVELOPE_LEFT | SDK_AUDIO_ENVELOPE_VOLUME,
            envelope->currentLeft, 0, 0);
        SDK_AUDIO_VOLUME(cursor++, SDK_AUDIO_ENVELOPE_VOLUME, envelope->currentRight, 0, 0);
        SDK_AUDIO_VOLUME(cursor++, SDK_AUDIO_ENVELOPE_LEFT, envelope->leftTarget,
            envelope->leftRateHigh, envelope->leftRateLow);
        SDK_AUDIO_VOLUME(cursor++, 0, envelope->rightTarget,
            envelope->rightRateHigh, envelope->rightRateLow);
        SDK_AUDIO_VOLUME(cursor++, SDK_AUDIO_ENVELOPE_AUXILIARY, envelope->dryAmount, 0, envelope->wetAmount);
        SDK_AUDIO_ENVELOPE(cursor++, SDK_AUDIO_ENVELOPE_INITIALIZE | SDK_AUDIO_ENVELOPE_AUXILIARY,
            func_800606A0(envelope->state));
    } else {
        SDK_AUDIO_ENVELOPE(cursor++, SDK_AUDIO_ENVELOPE_CONTINUE | SDK_AUDIO_ENVELOPE_AUXILIARY,
            func_800606A0(envelope->state));
    }
    *input += samples << 1;
    envelope->delta += samples;
    return cursor;
}

double func_8006CDE8(double value, int *exponent)
{
    double magnitude;

    *exponent = 0;
    if (value == 0.0) {
        return value;
    }
    magnitude = value > 0.0 ? value : -value;
    for (; magnitude >= 1.0; magnitude *= 0.5) {
        ++*exponent;
    }
    for (; magnitude < 0.5; magnitude += magnitude) {
        --*exponent;
    }
    return value > 0.0 ? magnitude : -magnitude;
}

double func_8006CDC0(double value, int exponent)
{
    int multiplier;

    if (exponent) {
        multiplier = 1 << exponent;
        value *= (double)multiplier;
    }
    return value;
}

static short getRate(double volume, double target, int samples, unsigned short *low)
{
    short integerPart;
    double inverse = 1.0 / samples, epsilon, multiplier, factor, mantissa;
    int exponentBits, exponent, index;

    if (samples == 0) {
        if (target >= volume) {
            *low = 0xFFFF;
            return 0x7FFF;
        } else {
            *low = 0;
            return 0;
        }
    }
    if (target < 1.0) {
        target = 1.0;
    }
    if (volume <= 0) {
        volume = 1;
    }
    {
        double logTable[] = {
            -0.912537, -0.752072, -0.607683, -0.476438,
            -0.356144, -0.245112, -0.142019, -0.045804
        };

        exponentBits = (int)func_8006CDC0(inverse, 30);
        mantissa = func_8006CDE8(target / volume, &exponent);
        index = (int)func_8006CDC0(mantissa, 4);
        epsilon = (logTable[index - 8] + exponent) * 0.69314718055994530942;
        epsilon /= func_8006CDC0(1, 30);
        factor = 1.0 + epsilon;
        multiplier = 1.0;
        while (exponentBits) {
            if (exponentBits & 1) {
                multiplier *= factor;
            }
            factor *= factor;
            exponentBits >>= 1;
        }
    }
    multiplier *= (multiplier *= (multiplier *= multiplier));
    integerPart = (short)multiplier;
    *low = (short)(0xFFFF * (multiplier - (float)integerPart));
    return (short)multiplier;
}

static float getVolume(float initial, int samples, short high, unsigned short low)
{
    float rate, multiplier;
    int index;

    samples >>= 3;
    if (samples == 0) {
        return initial;
    }
    rate = ((float)(high << 16) + (float)low) / 65536;
    multiplier = 1.0;
    for (index = 0; index < 32; index++) {
        if (samples & 1) {
            multiplier *= rate;
        }
        samples >>= 1;
        if (samples == 0) {
            break;
        }
        rate *= rate;
    }
    initial *= multiplier;
    return initial;
}
