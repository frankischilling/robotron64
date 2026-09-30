#ifndef ROBOTRON_AUDIO_CONFIG_H
#define ROBOTRON_AUDIO_CONFIG_H

typedef struct AudioConfiguration {
    unsigned int flags;
    unsigned int values[14];
} AudioConfiguration;

typedef char AudioConfigurationMustBe60Bytes[sizeof(AudioConfiguration) == 0x3C ? 1 : -1];

void func_80052780(AudioConfiguration *configuration);
void func_80052948(AudioConfiguration *configuration);

#endif
