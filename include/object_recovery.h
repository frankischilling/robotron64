#ifndef ROBOTRON_OBJECT_RECOVERY_H
#define ROBOTRON_OBJECT_RECOVERY_H

typedef struct ObjectRecoveryDatPoint {
    short x;
    short y;
    short z;
    short unused;
} ObjectRecoveryDatPoint;

typedef struct ObjectRecoveryDatRecord {
    int x;
    int y;
    int z;
    unsigned char payload[88];
} ObjectRecoveryDatRecord;

typedef union ObjectRecoveryDatCount {
    int count;
    struct {
        short count;
        short scale;
    } scaled;
} ObjectRecoveryDatCount;

typedef struct ObjectRecoveryDatSection {
    void *data;
    ObjectRecoveryDatCount info;
} ObjectRecoveryDatSection;

typedef struct ObjectRecoveryDatFile {
    ObjectRecoveryDatSection sections[4];
    int selectedRecord;
    void *tailData;
} ObjectRecoveryDatFile;

ObjectRecoveryDatFile *func_8003C6B8(ObjectRecoveryDatFile *file);
int func_8003CC58(int angle);
int func_8003CC88(int angle);
int func_8003CCB8(int angle);
int func_8003CCE8(int value);
unsigned char *func_8003CBEC(unsigned char *destination, unsigned char *source);
int func_8003CD4C(int x, int y);
int func_8003CD70(int x, int y);
int func_8003CEF4(int value);

#endif
