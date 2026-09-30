#include "../../include/actor_animation_state.h"
#include "../../include/actor_resource_internal.h"
#include "../../include/scene_commands_internal.h"
#include "../../include/frame_slot.h"

void func_80029E5C(ActorBehaviorActorInternal *actor)
{
    ActorBehaviorActorInternal *child;

    child = (ActorBehaviorActorInternal *)
        func_8001F240(&D_800ACE58[actor->resource24->actorKind + 4],
                     actor->position);
    child->field2C = child->resource24->speed / 10;
    child->field6C =
        (func_8003CC88((func_8004CDE8() >> 3) % 0x1000) *
         child->resource24->speed / 10) / 0x1000;
    child->field70 =
        (func_8003CC58((func_8004CDE8() >> 3) % 0x1000) *
         child->resource24->speed / 10) / 0x1000;
    func_80039514(child->objectIndex, (func_8004CDE8() >> 3) % 0x1000);
    if (child != 0) {
        func_8004E7D4((FrameSlotState *)child);
    }
    func_80029D98(actor);
}
