#include "../../../include/actor_resource_internal.h"

ActorResourceGroupInternal D_8009EA18[1];
int D_8009EE04;

typedef char EarlyResourceGroupMustBe1004Bytes[
    sizeof(D_8009EA18) == 0x3EC ? 1 : -1];
