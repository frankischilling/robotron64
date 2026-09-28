#include "../../include/audio_commands.h"

extern unsigned int D_8008D844;

void func_8005AFE4(int value);
int func_8005AFF0(void);

void func_80053F78(int index, int useArgument, int argument)
{
    unsigned char remaining;
    unsigned char active;
    AudioInstance *instance;
    AudioVoice *voice;
    unsigned char *indices;
    int slots;
    int voices;
    int previous;

    if (func_80052ACC(index) != 0) {
        func_8005895C();
        remaining = D_8008D844;
        active = D_801902EC->activeCount;
        instance = D_801902EC->instances;
        if (active != 0) {
            if (useArgument) {
                previous = func_8005AFF0();
                func_8005AFE4(argument);
            }
            while (remaining--) {
                if (instance->active) {
                    if (index == instance->index && instance->flag08) {
                        voices = instance->voiceCount;
                        instance->flag08 = 0;
                        indices = instance->voiceIndices;
                        slots = D_801902EC->voiceIndexCount;
                        while (slots--) {
                            if (*indices != 255) {
                                voice = &D_801902EC->voices[*indices];
                                D_8008D800[voice->backend]->stopVoice(voice);
                                if (--voices == 0) {
                                    break;
                                }
                            }
                            indices++;
                        }
                    }
                    if (--active == 0) {
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
