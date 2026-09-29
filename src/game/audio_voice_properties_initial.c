#include "audio_properties_internal.h"

void func_800557FC(AudioVoice *voice, AudioProperties *properties)
{
    unsigned char *savedCommand;
    unsigned int fields;
    unsigned char command[4];

    if (properties && properties->fields) {
        fields = properties->fields;
        if (fields & 1) {
            savedCommand = voice->command;
            voice->command = command;
            voice->command[0] = 12;
            voice->command[1] = properties->parameter04;
            D_8008D800[voice->backend]->commands[5](voice);
            voice->command = savedCommand;
        }
        if (fields & 2) {
            savedCommand = voice->command;
            voice->command = command;
            voice->command[0] = 13;
            voice->command[1] = properties->parameter05;
            D_8008D800[voice->backend]->commands[6](voice);
            voice->command = savedCommand;
        }
        if (fields & 4) {
            voice->property04 = properties->parameter06;
        }
        if (fields & 8) {
            savedCommand = voice->command;
            voice->command = command;
            voice->command[0] = 9;
            voice->command[1] = properties->parameter08 & 255;
            voice->command[2] = (properties->parameter08 >> 8) & 255;
            D_8008D800[voice->backend]->commands[2](voice);
            voice->command = savedCommand;
        }
        if (fields & 16) {
            if (voice->controlMask & (1 << properties->parameter0A)) {
                voice->flag40 = 1;
            } else {
                voice->flag40 = 0;
            }
        }
        if (fields & 32) {
            voice->property16 = properties->parameter0C;
            voice->property1C = func_800589E4(func_800589DC(), voice->property14,
                                            (short)voice->property16);
        }
        if (fields & 64) {
            voice->position2C = voice->position28 + properties->offset10;
            voice->flag08 = 1;
        }
        if (fields & 128) {
            voice->flag04 = 1;
        }
    }
}
