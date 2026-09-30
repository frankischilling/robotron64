#ifndef ROBOTRON_ACTOR_DYNAMIC_POOL_INTERNAL_H
#define ROBOTRON_ACTOR_DYNAMIC_POOL_INTERNAL_H

/* Fixed heap extent and record strides are established by complete callers.
 * The 1,240-byte first region and each 200-byte group tail remain unresolved. */
typedef struct ActorDynamicCommand {
    int opcode;
    int value04;
} ActorDynamicCommand;

typedef struct ActorDynamicPair {
    int index;
    int value;
} ActorDynamicPair;

typedef struct ActorDynamicPairGroup {
    int count;
    ActorDynamicPair pairs[50];
    unsigned char unknown194[200];
} ActorDynamicPairGroup;

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
    unsigned char unknown010[1240];
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
typedef char ActorDynamicParameterMustBe36Bytes[sizeof(ActorDynamicParameter) == 36 ? 1 : -1];
typedef char ActorDynamicPoolMustBe9096Bytes[sizeof(ActorDynamicPool) == 9096 ? 1 : -1];

void func_8000CEC0(ActorDynamicCommand *command);
void func_8000D1FC(ActorDynamicCommand *command);
void func_8000D2D4(ActorDynamicParameterCommand *command);

#endif
