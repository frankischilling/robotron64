#include "../../include/audio_engine_tables_internal.h"

void func_800596C4(AudioContext *context);
void func_800596FC(AudioContext *context);
void func_80059704(AudioVoice *voice);
void func_8005970C(AudioVoice *voice);
void func_80059714(AudioVoice *voice);
void func_8005971C(AudioVoice *voice);
void func_80059898(AudioVoice *voice);
void func_800598A0(AudioVoice *voice);
void func_800598C8(AudioVoice *voice);
void func_800598D0(AudioVoice *voice);
void func_800598F4(AudioVoice *voice);
void func_800598FC(AudioVoice *voice);
void func_80059904(AudioVoice *voice);
void func_80059920(AudioVoice *voice);
void func_8005993C(AudioVoice *voice);
void func_80059944(AudioVoice *voice);
void func_8005994C(AudioVoice *voice);
void func_80059954(AudioVoice *voice);
void func_8005995C(AudioVoice *voice);
void func_80059964(AudioVoice *voice);
void func_80059A88(AudioVoice *voice);
void func_80059B68(AudioVoice *voice);
void func_80059C54(AudioVoice *voice);
void func_80059D20(AudioVoice *voice);
void func_80059DEC(AudioVoice *voice);
void func_80059E2C(AudioVoice *voice);
void func_80059FC8(AudioVoice *voice);
void func_8005A180(AudioVoice *voice);
void func_8005A310(AudioVoice *voice);
void func_8005A448(AudioVoice *voice);
void func_8005A6D8(AudioVoice *voice);
void func_8005A73C(AudioVoice *voice);
void func_8005A7C4(AudioVoice *voice);
void func_8005A830(AudioVoice *voice);
void func_8005A88C(AudioVoice *voice);
void func_8005A9A4(AudioVoice *voice);

AudioEngineCommandTable D_8008D920 = {
    func_800596C4,
    func_800596FC,
    {func_80059704, func_8005970C, func_80059714},
    func_8005971C,
    func_80059898,
    {
        func_800598A0, func_800598C8, func_800598D0, func_800598F4,
        func_800598FC, func_80059904, func_80059920, func_8005993C,
        func_80059944, func_8005994C, func_80059954, func_8005995C
    },
    {
        func_80059964, func_80059A88, func_80059B68, func_80059C54,
        func_80059D20, func_80059DEC, func_80059E2C, func_80059FC8,
        func_8005A180, func_8005A310, func_8005A448, func_8005A6D8,
        func_8005A73C, func_8005A7C4, func_8005A830, func_8005A88C,
        func_8005A9A4
    }
};
