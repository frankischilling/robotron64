#include "../../../../include/audio_backend_internal.h"

void func_8005B3A8(AudioContext *context);
void func_8005B66C(AudioContext *context);
void func_8005B674(AudioVoice *voice);
void func_8005B7AC(AudioVoice *voice);
void func_8005B7B4(AudioVoice *voice);
void func_8005B7BC(AudioVoice *voice);
void func_8005B9F8(AudioVoice *voice);
void func_8005BA1C(AudioVoice *voice);
void func_8005BA24(AudioVoice *voice);
void func_8005C32C(AudioVoice *voice);

AudioOperations D_8008D9D0 = {
    func_8005B3A8,
    func_8005B66C,
    func_8005B674,
    {func_8005B7AC, func_8005B7B4},
    func_8005B7BC,
    func_8005B854,
    {
        func_8005B9F8, func_8005BA1C, func_8005BA24, func_8005BCC8,
        func_8005BCD0, func_8005BCD8, func_8005BEFC, func_8005C0A0,
        func_8005C1D8, func_8005C32C, func_8005CA34, func_8005CBB4
    }
};
