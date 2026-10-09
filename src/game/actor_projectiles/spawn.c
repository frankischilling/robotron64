#include "../../../include/actor_projectile_spawn_internal.h"

EarlyGameActor *func_80038D8C(EarlyGamePosition *position, int kind, ActorBehaviorPlayerInternal *owner, int angle)
{
  EarlyGameActor *actor;
  int i;
  ActorResource5CInternal *resource;
  int count;
  EarlyGamePosition start;
  if (((kind == 3) || (kind == 1)) || (kind == 2))
  {
    count = 1;
  }
  else
  {
    count = 3;
  }
  start = *position;
  start.value[2] -= 350;
  for (i = 0; i < count; i++)
  {
    resource = &D_800AC998[kind];
    actor = (EarlyGameActor *) func_800283D4(4, (TextGlyphResource *) resource, start.value);
    if (actor != 0)
    {
      /* Set the spawned flag before selecting the resource behavior. */
      if ((actor->flags14 |= 0x1000, resource) == (&D_800AC998[1]))
      {
        func_80039C50(actor->objectIndex0C, 4);
        func_80039BE4(actor->objectIndex0C, 3);
        actor->field54 = ((TextGlyphResource *) actor->resource24)->speed;
        actor->position.value[2] = -2500;
        actor->callback00 = func_80005560;
      }
      else
        if (resource == (&D_800ACA50))
      {
        func_80039C50(actor->objectIndex0C, 4);
        actor->field54 = ((TextGlyphResource *) actor->resource24)->speed;
        actor->callback00 = func_80005560;
      }
      else
        if (resource == (&D_800ACAAC))
      {
        actor->field54 = 0;
        func_80039C50(actor->objectIndex0C, 4);
      }
      else
      {
        if (i != 0)
        {
          actor->flags14 |= 0x100;
        }
        actor->field54 = (((TextGlyphResource *) actor->resource24)->speed * (7 - i)) / 7;
      }
      actor->angle08 = angle;
      actor->field2C = actor->field54;
      actor->field6C = (func_8003CC88(angle) * actor->field54) / 4096;
      actor->field70 = (func_8003CC58(angle) * actor->field54) / 4096;
      func_80039514(actor->objectIndex0C, angle);
      actor->position.value[0] += ((func_8004CDE8() >> 3) % 2) * D_800AC98C;
      actor->position.value[1] += ((func_8004CDE8() >> 3) % 2) * D_800AC98C;
      actor->position.value[0] += D_8009EF94 * owner->actor08->field6C;
      actor->position.value[1] += D_8009EF94 * owner->actor08->field70;
      if (resource == (&D_800AC9F4))
      {
        actor->field6C += owner->actor08->field6C;
        actor->field70 += owner->actor08->field70;
      }
      if (angle > 2048)
      {
        actor->position.value[1] -= 100;
      }
      if (resource == (&D_800AC998[0]))
      {
        actor->field2C = 1;
        actor->field6C = func_8003CC88(angle) / 4096;
        actor->field70 = func_8003CC58(angle) / 4096;
        func_80039514(actor->objectIndex0C, angle);
      }
      actor->owner3C = (EarlyGameActorOwner *) owner;
    }
  }

  return actor;
}
