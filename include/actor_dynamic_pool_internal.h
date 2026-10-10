#ifndef ROBOTRON_ACTOR_DYNAMIC_POOL_INTERNAL_H
#define ROBOTRON_ACTOR_DYNAMIC_POOL_INTERNAL_H

/* The allocator and complete appenders establish the fixed heap and strides. */
typedef struct ActorDynamicCommand {
    int opcode;
    int value04;
} ActorDynamicCommand;

typedef struct ActorDynamicPair {
    int index;
    int value;
} ActorDynamicPair;

typedef struct ActorDynamicFirstEntry {
    int resourceIndex;
    int x;
    int y;
} ActorDynamicFirstEntry;

typedef struct ActorDynamicFirstGroup {
    int count;
    ActorDynamicFirstEntry entries[10];
} ActorDynamicFirstGroup;

typedef struct ActorDynamicFirstCommand {
    int opcode;
    int resourceIndex;
    int x;
    int y;
} ActorDynamicFirstCommand;

typedef struct ActorDynamicPairGroup {
    int count;
    ActorDynamicPair pairs[50];
    int distances[50];
} ActorDynamicPairGroup;

typedef struct ActorDynamicPointCommand {
    int opcode;
    int x;
    int y;
} ActorDynamicPointCommand;

typedef struct ActorDynamicParameter {
    int value00;
    int value04;
    int value08;
    int value0C;
    int value10;
    int value14;
    int value18;
    int value1C;
    int value20;
} ActorDynamicParameter;

typedef struct ActorDynamicPool {
    int value00;
    int groupCount;
    int pairGroupCount;
    int parameterCount;
    ActorDynamicFirstGroup firstGroups[10];
    ActorDynamicPairGroup pairGroups[10];
    ActorDynamicParameter parameters[50];
} ActorDynamicPool;

typedef struct ActorDynamicParameterCommand {
    int opcode;
    int value04;
    int value08;
    int value0C;
    int value10;
    int value14;
    int value18;
    int value1C;
    int value20;
    int value24;
} ActorDynamicParameterCommand;

typedef char ActorDynamicPairGroupMustBe604Bytes[sizeof(ActorDynamicPairGroup) == 604 ? 1 : -1];
typedef char ActorDynamicPointCommandMustBe12Bytes[
    sizeof(ActorDynamicPointCommand) == 12 ? 1 : -1];
typedef char ActorDynamicFirstEntryMustBe12Bytes[
    sizeof(ActorDynamicFirstEntry) == 12 ? 1 : -1];
typedef char ActorDynamicFirstGroupMustBe124Bytes[
    sizeof(ActorDynamicFirstGroup) == 124 ? 1 : -1];
typedef char ActorDynamicFirstCommandMustBe16Bytes[
    sizeof(ActorDynamicFirstCommand) == 16 ? 1 : -1];
typedef char ActorDynamicParameterMustBe36Bytes[sizeof(ActorDynamicParameter) == 36 ? 1 : -1];
typedef char ActorDynamicPoolMustBe9096Bytes[sizeof(ActorDynamicPool) == 9096 ? 1 : -1];

void func_8000CEC0(ActorDynamicCommand *command);
void func_8000CF9C(ActorDynamicFirstCommand *command);
void func_8000D090(ActorDynamicPointCommand *command);
void func_8000DFB0(int *x, int *y);
void func_8000D1FC(ActorDynamicCommand *command);
void func_8000D2D4(ActorDynamicParameterCommand *command);

extern ActorDynamicPool *D_800AE4F4;

extern char D_8008F9A8[24];
extern unsigned char D_8008F9C0[52];
extern char D_8008F9F4[24];
extern char D_8008FA0C[29];

#endif
