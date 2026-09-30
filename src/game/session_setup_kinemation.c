#include "../../include/session_setup_internal.h"

void func_8002F29C(SessionSetupCommand *command)
{
    int name;
    int duration;
    unsigned char previousEntryOffset;
    int sound;
    int soundMode;
    SessionSetupKinemation *kinemation;

    name = command->argument0;
    duration = command->argument1;
    sound = command->argument3;
    soundMode = command->argument4;
    if (!D_80077AD0->flags04.bits.loaded) {
        if (name != -2) {
            func_800383C4(name);
        }
        previousEntryOffset = 1;
        kinemation = &((D_800AA710 + D_800AC970) - previousEntryOffset)->setup.kinemation;
        kinemation->name = name;
        kinemation->duration = duration;
        kinemation->sound = sound;
        kinemation->soundMode = soundMode;
    }
}
