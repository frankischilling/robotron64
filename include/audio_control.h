#ifndef ROBOTRON_AUDIO_CONTROL_H
#define ROBOTRON_AUDIO_CONTROL_H

typedef struct AudioRecordSlot {
    unsigned int unknown00[3];
    void *value;
} AudioRecordSlot;

typedef struct AudioRecordTable {
    unsigned int unknown00[8];
    AudioRecordSlot *slots;
} AudioRecordTable;

typedef struct AudioInstance {
    unsigned int active : 1;
    unsigned int flag40 : 1;
    unsigned int flag20 : 1;
    unsigned int flag10 : 1;
    unsigned int flag08 : 1;
    unsigned int unknownFlags : 3;
    unsigned char state;
    short index;
    unsigned char voiceCount;
    unsigned char unknown05[3];
    unsigned int unknown08;
    unsigned char *voiceIndices;
    unsigned int unknown10[2];
} AudioInstance;

typedef struct AudioVoice {
    unsigned char unknown00[3];
    unsigned char category;
    unsigned char unknown04[9];
    unsigned char parameter0D;
    unsigned char unknown0E[2];
    unsigned char backend;
    unsigned char unknown11[0x23];
    unsigned char *command;
    unsigned char unknown38[0x18];
} AudioVoice;

typedef struct AudioContext {
    unsigned int unknown00;
    unsigned char activeCount;
    unsigned char unknown05[5];
    unsigned char voiceIndexCount;
    unsigned char unknown0B;
    AudioRecordTable *table;
    unsigned int unknown10[2];
    AudioInstance *instances;
    AudioVoice *voices;
} AudioContext;

typedef char AudioInstanceMustBe24Bytes[sizeof(AudioInstance) == 0x18 ? 1 : -1];
typedef char AudioVoiceMustBe80Bytes[sizeof(AudioVoice) == 0x50 ? 1 : -1];

typedef void (*AudioErrorCallback)(void *argument, int error);

typedef struct AudioOperations {
    void *unknown00;
    void (*release)(AudioContext *context);
    void *unknown08[3];
    void (*stopVoice)(AudioVoice *voice);
    void *unknown18[6];
    void (*updateVoice)(AudioVoice *voice);
} AudioOperations;

extern AudioOperations *D_8008D800[];

void func_80052A00(int error);
void func_80052A38(unsigned char *destination, unsigned int count);
void func_80052A60(AudioErrorCallback callback, void *argument);
AudioContext *func_80052A74(void);
int func_80052A84(void);
int func_80052AA8(void);
int func_80052ACC(int index);
void func_80052B40(void);
void func_80052B64(void);
void func_80052B84(void);
int func_80052BA4(void);
void func_80052C08(int release);
void *func_80052C84(void);
void *func_80052C94(void);
void func_80052CA4(void);
void func_80052CF4(void);

#endif
