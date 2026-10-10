#include "../../include/actor_setup_internal.h"
#include "../../include/debug_output.h"
#include "../../include/actor_dynamic_pool_internal.h"

void func_8000D2D4(ActorDynamicParameterCommand *command)
{
    int first = command->value04;
    int second = command->value08;
    int third = command->value0C;
    int fourth = command->value10;
    int fifth = command->value14;
    int sixth = command->value18;
    int seventh = command->value1C;
    int eighth = command->value20;
    int ninth = command->value24;
    ActorDynamicPool *pool = (ActorDynamicPool *)D_800AE4F4;
    ActorDynamicParameter *parameter = &pool->parameters[pool->parameterCount];

    parameter->value00 = first;
    parameter->value04 = second;
    parameter->value14 = third;
    parameter->value18 = fourth;
    parameter->value0C = fifth;
    parameter->value08 = sixth;
    parameter->value10 = seventh;
    parameter->value1C = eighth;
    parameter->value20 = ninth;
    ((ActorDynamicPool *)D_800AE4F4)->parameterCount++;
    if (((ActorDynamicPool *)D_800AE4F4)->parameterCount == 50) {
        func_8001C2C4(D_8008FA0C);
    }
}

char D_8008FA0C[] = "Num wave instances exceeded\n";
