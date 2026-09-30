#include "../../include/audio_config.h"

extern unsigned int D_8008D828;
extern unsigned int D_8008D82C;
extern unsigned int D_8008D830;
extern unsigned int D_8008D834;
extern unsigned int D_8008D838;
extern unsigned int D_8008D83C;
extern unsigned int D_8008D840;
extern unsigned int D_8008D844;
extern unsigned int D_8008D848;
extern unsigned int D_8008D84C;
extern unsigned int D_8008D850;
extern unsigned int D_8008D854;
extern unsigned int D_8008D858;
extern unsigned int D_8008D85C;

void func_80052780(AudioConfiguration *configuration)
{
    if (configuration->flags & 0x0001) {
        D_8008D828 = configuration->values[0];
    }
    if (configuration->flags & 0x0002) {
        D_8008D82C = configuration->values[1];
    }
    if (configuration->flags & 0x0004) {
        D_8008D830 = configuration->values[2];
    }
    if (configuration->flags & 0x0008) {
        D_8008D834 = configuration->values[3];
    }
    if (configuration->flags & 0x0010) {
        D_8008D838 = configuration->values[4];
    }
    if (configuration->flags & 0x0020) {
        D_8008D83C = configuration->values[5];
    }
    if (configuration->flags & 0x0040) {
        D_8008D840 = configuration->values[6];
    }
    if (configuration->flags & 0x0080) {
        D_8008D844 = configuration->values[7];
    }
    if (configuration->flags & 0x0100) {
        D_8008D848 = configuration->values[8];
    }
    if (configuration->flags & 0x0200) {
        D_8008D84C = configuration->values[9];
    }
    if (configuration->flags & 0x0400) {
        D_8008D850 = configuration->values[10];
    }
    if (configuration->flags & 0x0800) {
        D_8008D854 = configuration->values[11];
    }
    if (configuration->flags & 0x1000) {
        D_8008D858 = configuration->values[12];
    }
    if (configuration->flags & 0x2000) {
        D_8008D85C = configuration->values[13];
    }
}

void func_80052948(AudioConfiguration *configuration)
{
    configuration->flags = 0;
    configuration->values[0] = D_8008D828;
    configuration->values[1] = D_8008D82C;
    configuration->values[2] = D_8008D830;
    configuration->values[3] = D_8008D834;
    configuration->values[4] = D_8008D838;
    configuration->values[5] = D_8008D83C;
    configuration->values[6] = D_8008D840;
    configuration->values[7] = D_8008D844;
    configuration->values[8] = D_8008D848;
    configuration->values[9] = D_8008D84C;
    configuration->values[10] = D_8008D850;
    configuration->values[11] = D_8008D854;
    configuration->values[12] = D_8008D858;
    configuration->values[13] = D_8008D85C;
}
