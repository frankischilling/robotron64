#include "audio_properties_internal.h"

void func_80055F24(int ownerTag, int useArgument, int argument)
{
    unsigned char remaining;
    unsigned char active;
    AudioInstance *instance;
    AudioVoice *voice;
    unsigned char *indices;
    int slots;
    int voices;
    int previous;

    if (func_80052AA8()) {
        func_8005895C();
        remaining = D_8008D844;
        active = D_801902EC->activeCount;
        instance = D_801902EC->instances;
        if (active) {
            if (useArgument) {
                previous = func_8005AFF0();
                func_8005AFE4(argument);
            }
            while (remaining--) {
                if (instance->active) {
                    if (ownerTag == instance->ownerTag && instance->flag08) {
                        instance->flag08 = 0;
                        voices = instance->voiceCount;
                        indices = instance->voiceIndices;
                        slots = D_801902EC->voiceIndexCount;
                        while (slots--) {
                            if (*indices != 255) {
                                voice = &D_801902EC->voices[*indices];
                                D_8008D800[voice->backend]->stopVoice(voice);
                                if (!--voices) {
                                    break;
                                }
                            }
                            indices++;
                        }
                    }
                    if (!--active) {
                        break;
                    }
                }
                instance++;
            }
            if (useArgument) {
                func_8005AFE4(previous);
            }
        }
        func_8005899C();
    }
}
