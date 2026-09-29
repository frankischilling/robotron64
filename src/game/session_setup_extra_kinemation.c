#include "../../include/session_setup_internal.h"

void func_8002F334(SessionSetupCommand *command)
{
    int name;
    int duration;
    int soundModeCopy;
    int sound;
    int soundMode;
    int durationCopy;
    SessionSetupKinemation *kinemation;

    name = command->argument0;
    duration = command->argument1;
    sound = command->argument3;
    soundMode = command->argument4;
    if (name != -2) {
        func_800383C4(name);
    }
    soundModeCopy = soundMode;
    if (D_800A4578 >= 4) {
        func_8001C0D0(D_80093E94);
    }
    kinemation = &D_800A4538[D_800A4578++].setup.kinemation;
    func_8003B694(kinemation, -1, sizeof(SessionSetupKinemation));
    kinemation->name = name;
    durationCopy = duration;
    kinemation->duration = durationCopy;
    kinemation->sound = sound;
    kinemation->soundMode = soundModeCopy;
}
