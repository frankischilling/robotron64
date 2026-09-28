#include "../../include/audio_properties_internal.h"

void func_80057D68(int handle, int slot, unsigned char first, unsigned char second)
{
    AudioVoice *voice;
    unsigned char *savedCommand;

    if (func_80052AA8()) {
        func_8005895C();
        voice = func_800564E0(handle, slot);
        if (voice) {
            savedCommand = voice->command;
            voice->command = D_80190300;
            voice->command[0] = 17;
            voice->command[1] = first;
            voice->command[2] = second;
            D_8008D800[voice->backend]->command44(voice);
            voice->command = savedCommand;
        }
        func_8005899C();
    }
}
