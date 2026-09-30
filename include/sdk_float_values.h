#ifndef ROBOTRON_SDK_FLOAT_VALUES_H
#define ROBOTRON_SDK_FLOAT_VALUES_H

/* Word initializers retain the SDK's exact IEEE-754 coefficients. */
typedef union SdkDoubleValue {
    unsigned int words[2];
    double value;
} SdkDoubleValue;

typedef union SdkFloatValue {
    unsigned int word;
    float value;
} SdkFloatValue;

typedef char SdkDoubleValueSize[(sizeof(SdkDoubleValue) == 8) ? 1 : -1];
typedef char SdkFloatValueSize[(sizeof(SdkFloatValue) == 4) ? 1 : -1];

#endif
