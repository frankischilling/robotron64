#include "../../../include/audio_properties_internal.h"
#include "../../../include/audio_engine_tables_internal.h"

unsigned int func_80057124(AudioVoice *voice, unsigned int position, unsigned char **command)
{
    unsigned int time;
    unsigned char *data;
    unsigned int delay;
    int code;
    int reached;
    int unused[1]; /* Preserve the retail decoder scratch slot at sp + 0x54. */

    delay = 0;
    time = 0;
    voice->command = voice->data;
    data = voice->command;
    voice->command = func_80059580(voice->command, &delay);
    for (;;) {
        time += delay;
        if (time >= position) {
            reached = 1;
            break;
        }
        code = *voice->command;
        if (code == 34) {
            reached = 0;
            break;
        }
        if (code != 17 && code != 18) {
            if (code >= 7 && code < 19) {
                D_8008D800[voice->backend]->commands[code - 7](voice);
                voice->command += D_8008D8D0[code];
                data = voice->command;
                voice->command = func_80059580(voice->command, &delay);
            } else if (code >= 19 && code < 36) {
                D_8008D96C[code - 19](voice);
                if (!voice->commandRedirect) {
                    voice->command += D_8008D8D0[code];
                    data = voice->command;
                    voice->command = func_80059580(voice->command, &delay);
                } else {
                    voice->commandRedirect = 0;
                }
            } else {
                D_8008D96C[10](voice);
            }
        } else {
            voice->command += D_8008D8D0[code];
            data = voice->command;
            voice->command = func_80059580(voice->command, &delay);
        }
    }
    if (reached) {
        voice->delay = time - position;
        voice->unknown20 = 0;
        voice->position28 = position;
    } else {
        voice->delay = 0;
        voice->unknown20 = 0;
        voice->position28 = time;
    }
    *command = data;
    return voice->position28;
}
