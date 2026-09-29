#include "../../include/audio_commands.h"

extern unsigned int D_8008D844;
extern unsigned char D_8008DA1C;

void func_800547FC(unsigned char value)
{
    unsigned char remaining;
    unsigned char active;
    AudioInstance *instance;
    AudioVoice *voice;
    unsigned char *indices;
    unsigned char *previous;
    unsigned char command[2];
    int slots;
    int voices;

    if (func_80052AA8() != 0) {
        D_8008DA1C = value;
        func_8005895C();
        remaining = D_8008D844;
        active = D_801902EC->activeCount;
        instance = D_801902EC->instances;
        if (active != 0) {
            while (remaining--) {
                if (instance->active) {
                    voices = instance->voiceCount;
                    slots = D_801902EC->voiceIndexCount;
                    indices = instance->voiceIndices;
                    while (slots--) {
                        if (*indices != 255) {
                            voice = &D_801902EC->voices[*indices];
                            if (voice->category == 0) {
                                previous = voice->command;
                                voice->command = command;
                                command[0] = 12;
                                voice->command[1] = voice->parameter0D;
                                voice->parameter0D = 0;
                                D_8008D800[voice->backend]->commands[5](voice);
                                voice->command = previous;
                            }
                            if (--voices == 0) {
                                break;
                            }
                        }
                        indices++;
                    }
                    if (--active == 0) {
                        break;
                    }
                }
                instance++;
            }
        }
        func_8005899C();
    }
}
