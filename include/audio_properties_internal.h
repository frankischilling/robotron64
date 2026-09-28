#ifndef ROBOTRON_AUDIO_PROPERTIES_INTERNAL_H
#define ROBOTRON_AUDIO_PROPERTIES_INTERNAL_H

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
    unsigned char runningVoiceCount;
    unsigned char unknown06[2];
    int ownerTag;
    unsigned char *voiceIndices;
    unsigned int unknown10[2];
} AudioInstance;

typedef struct AudioVoice {
    unsigned int flag80 : 1;
    unsigned int flag40 : 1;
    unsigned int flag20 : 1;
    unsigned int paused : 1;
    unsigned int flag08 : 1;
    unsigned int flag04 : 1;
    unsigned int commandRedirect : 1;
    unsigned int unknownFlags : 1;
    unsigned char unknown01;
    unsigned char unknown02;
    unsigned char category;
    short property04;
    short property06;
    unsigned int delay;
    unsigned char unknown0C;
    unsigned char parameter0D;
    unsigned char parameter0E;
    unsigned char controlMask;
    unsigned char backend;
    unsigned char unknown11;
    short unknown12;
    short property14;
    short property16;
    short unknown18;
    short record1A;
    int property1C;
    int unknown20;
    int unknown24;
    int position28;
    int position2C;
    unsigned char *data;
    unsigned char *command;
    int value38;
    unsigned char unknown3C[0x10];
    void *record4C;
} AudioVoice;

typedef struct AudioCallbackRecord {
    unsigned char active;
    unsigned char code;
    unsigned char unknown02;
    unsigned char unknown03;
    int value;
} AudioCallbackRecord;

typedef struct AudioContext {
    unsigned int unknown00;
    unsigned char activeCount;
    unsigned char unknown05[4];
    unsigned char callbackCount;
    unsigned char voiceIndexCount;
    unsigned char unknown0B;
    AudioRecordTable *table;
    AudioCallbackRecord *callbacks;
    unsigned int unknown14;
    AudioInstance *instances;
    AudioVoice *voices;
} AudioContext;

typedef struct AudioOperations {
    void *unknown00;
    void (*release)(AudioContext *context);
    void *unknown08[3];
    void (*stopVoice)(AudioVoice *voice);
    void (*pauseVoice)(AudioVoice *voice);
    void (*command1C)(AudioVoice *voice);
    void (*command20)(AudioVoice *voice);
    void (*command24)(AudioVoice *voice);
    void (*command28)(AudioVoice *voice);
    void (*command2C)(AudioVoice *voice);
    void (*updateVoice)(AudioVoice *voice);
    void (*command34)(AudioVoice *voice);
    void (*command38)(AudioVoice *voice);
    void (*command3C)(AudioVoice *voice);
    void (*command40)(AudioVoice *voice);
    void (*command44)(AudioVoice *voice);
    void (*command48)(AudioVoice *voice);
} AudioOperations;

typedef struct AudioProperties {
    unsigned int fields;
    unsigned char parameter04;
    unsigned char parameter05;
    short parameter06;
    short parameter08;
    unsigned char parameter0A;
    unsigned char unknown0B;
    unsigned short parameter0C;
    unsigned short unknown0E;
    int offset10;
} AudioProperties;

typedef char AudioInstanceMustBe24Bytes[sizeof(AudioInstance) == 0x18 ? 1 : -1];
typedef char AudioVoiceMustBe80Bytes[sizeof(AudioVoice) == 0x50 ? 1 : -1];
typedef char AudioPropertiesMustBe20Bytes[sizeof(AudioProperties) == 0x14 ? 1 : -1];
typedef char AudioCallbackRecordMustBe8Bytes[sizeof(AudioCallbackRecord) == 8 ? 1 : -1];

extern AudioOperations *D_8008D800[];
extern unsigned int D_8008D844;
extern unsigned char D_8008D847;
extern unsigned char D_8008D857;
extern AudioContext *D_801902EC;

int func_80052AA8(void);
int func_80052ACC(int index);
int func_8005396C(AudioRecordSlot *slot, int index, int value, int flags, int argument);
void func_8005895C(void);
void func_8005899C(void);
short func_800589DC(void);
int func_800589E4(short time, short scale, short value);
void func_800592F0(int command);
void func_80059348(const void *source, int count);
void func_800593F4(void *destination, int count);
void func_8005AD94(int value);
void func_8005ADC4(void);
void func_8005ADD0(short index, unsigned char voiceIndex, AudioVoice *voice);
void func_8005AFE4(int value);
int func_8005AFF0(void);

void func_80054C50(AudioVoice *voice, AudioInstance *instance);
void func_80054CA0(AudioVoice *voice, AudioInstance *instance);
void func_80054DF8(int index, int update);
void func_800550AC(int index);
void func_8005530C(int useArgument, int argument);
void func_800555CC(int notify);
void func_800557FC(AudioVoice *voice, AudioProperties *properties);
void func_80055AE8(int ownerTag, AudioProperties *properties);
void func_80055D58(int ownerTag, int useArgument, int argument);
void func_80055F24(int ownerTag, int useArgument, int argument);
AudioInstance *func_80056480(int handle);
AudioVoice *func_800564E0(int handle, int slot);
void func_80056780(int handle, AudioProperties *properties);
void func_800568B8(int handle, int slot, AudioProperties *properties);
unsigned int func_80056EF0(AudioVoice *voice, unsigned int position, unsigned char **command);
unsigned int func_80057124(AudioVoice *voice, unsigned int position, unsigned char **command);
unsigned int func_80057610(int handle);
void func_800576E0(AudioVoice *voice, int value);
void func_80057744(AudioVoice *voice, int value);
void func_800577A8(AudioVoice *voice, int value);
void func_80057800(AudioVoice *voice, int value);
void func_80057858(AudioVoice *voice, int value, void (*callback)(AudioVoice *, int));
void func_8005789C(AudioVoice *voice, AudioProperties *properties);
void func_80057B08(AudioVoice *voice, AudioProperties *properties);
void func_80057D68(int handle, int slot, unsigned char first, unsigned char second);
void func_80057E3C(AudioVoice *voice, int value);
void func_80057EF0(AudioVoice *voice, int value);
void func_80057F74(AudioVoice *voice, int value);
void func_800581DC(int handle, int slot, int value, void (*callback)(AudioVoice *, int));
unsigned char *func_80059580(unsigned char *data, unsigned int *delay);
extern unsigned char D_80190300[];

#endif
