#include "../../../../include/audio_backend_internal.h"

void func_8005B064(AudioStatusRecord *hardware)
{
    static AudioVoice *voice;
    static unsigned int volume;
    static short pan;
    static int bend;
    static AudioSynthVoiceConfiguration configuration;
    static float pitch;
    static int attackTime;

    voice = &D_80192818[hardware->voiceIndex];
    if (D_8008DA24) {
        pan = voice->parameter0E + hardware->region->pan - 64;
        if (pan > 127) pan = 127;
        if (pan < 0) pan = 0;
    } else {
        pan = 64;
    }
    if (voice->category == 0) {
        volume = (unsigned int)(hardware->velocity * hardware->region->volume * voice->parameter0D * D_8008DA1C) >> 13;
    } else {
        volume = (unsigned int)(hardware->velocity * hardware->region->volume * voice->parameter0D * D_8008DA20) >> 13;
    }
    volume = (unsigned int)(hardware->region->attackVolume * volume) >> 7;
    if (voice->property06 == 0) {
        bend = 0;
    } else if (voice->property06 > 0) {
        bend = hardware->region->pitchUp * voice->property06 * 0.0122;
    } else {
        bend = hardware->region->pitchDown * voice->property06 * 0.0122;
    }
    if (hardware->priority >= 0 && hardware->priority < 128) {
        configuration.priority = hardware->priority;
    } else {
        configuration.priority = 127;
    }
    configuration.effectBus = 0;
    configuration.unityPitch = 0;
    func_80066448(D_8008F160, &D_80190200[hardware->index], &configuration);
    pitch = func_8005B000(hardware->wave->tuning + bend + (hardware->key - hardware->region->rootKey) * 100 - hardware->region->detune);
    attackTime = hardware->region->attackTime * 1000;
    func_80066590(D_8008F160, &D_80190200[hardware->index], &hardware->wave->sdk,
                   pitch, volume, pan, voice->unknown0C, attackTime);
}
