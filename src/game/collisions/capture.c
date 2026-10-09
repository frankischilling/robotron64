#include "../../../include/actor_collision_capture_internal.h"

int func_8001737C(ActorBehaviorActorInternal *first, ActorBehaviorActorInternal *second,
                  int *firstPosition, int *secondPosition)
{
  /* The three masked angle thresholds use signed slti instructions. */
  int angleDifference;
  GameActor *spawned;
  int direction;
  
  if ((second->resource24->actorKind < 4) && (second->animation1F == 0)) {
    switch (first->resource24->actorKind) {
    case 25:
    case 26:
    case 27:
    case 28:
      if (first->animation1F == 3) {
        break;
      }
      if (second->flags14 & 0x40) {
        second->flags14 &= ~0x40;
        second->callback44(second);
      }
      second->flags14 |= 0x40, second->callback44 = func_80029E5C, second->timer0E = 999;
      /* Copy all three position words before changing animation state. */
      *(TextValue3 *)second->position = *(TextValue3 *)first->position;
      func_80027AB8((GameActor *)second, 3, 1);
      second->field6C = 0;
      second->field70 = 0;
      first->field48 = D_8009EFA0;
      func_80027AB8((GameActor *)first, 3, 1);
      first->field6C = 0;
      first->field70 = 0;
      break;
    case 5:
      if (first->animation1F == 3) {
        break;
      }
      direction = func_8003CD4C(second->position[1] - first->position[1],
                            second->position[0] - first->position[0]);
      angleDifference = func_8004CEF0((short)direction - first->angle08);
      if (1000 < (angleDifference & 0x7ff)) {
        second->angle08 = first->angle08 & 0xfff;
        second->field48 = D_8009EFA0;
        func_80027AB8((GameActor *)second, 1, 1);
        if (second->flags14 & 0x40) {
          second->flags14 &= ~0x40;
          second->callback44(second);
        }
        second->flags14 |= 0x40, second->callback44 = func_80029154, second->timer0E = 999;
        *(TextValue3 *)second->position = *(TextValue3 *)first->position;
        func_800290B0(second->objectIndex, second->position);
        /* Retail still calls both trig helpers after clearing speed. */
        second->field2C = 0;
        func_8003CC88(second->angle08);
        second->field6C = 0;
        func_8003CC58(second->angle08);
        second->field70 = 0;
        func_80039514(second->objectIndex, second->angle08);
        func_80027AB8((GameActor *)first, 3, 1);
        first->field2C = 0;
        func_8003CC88(first->angle08);
        first->field6C = 0;
        func_8003CC58(first->angle08);
        first->field70 = 0;
        func_80039514(first->objectIndex, first->angle08);
        if (first->flags14 & 0x40) {
          first->flags14 &= ~0x40;
          first->callback44(first);
        }
        first->flags14 |= 0x40, first->callback44 = func_8002BF88, first->timer0E = 999;
        first->field4C = 500;
        spawned = func_800283D4(9,&D_800B2740, first->position);
        if (spawned != 0) {
          ((ActorContactSpawnInitializer)spawned->resource->field54)(spawned, 1);
          break;
        }
      }
      break;
    case 6:
      if (first->animation1F == 3) {
        break;
      }
      direction = func_8003CD4C(second->position[1] - first->position[1],
                            second->position[0] - first->position[0]);
      angleDifference = func_8004CEF0((short)direction - first->angle08);
      if (500 < (angleDifference & 0x7ff)) {
        func_80027AB8((GameActor *)first, 3, 1);
        if (first->flags14 & 0x40) {
          first->flags14 &= ~0x40;
          first->callback44(first);
        }
        first->flags14 |= 0x40, first->callback44 = func_80029210, first->timer0E = 999;
        direction = func_8003CD4C(second->position[1] - first->position[1],
                              second->position[0] - first->position[0]);
        first->angle08 = (short)direction;
        second->field2C = 0;
        func_8003CC88(second->angle08);
        second->field6C = 0;
        func_8003CC58(second->angle08);
        second->field70 = 0;
        func_80039514(second->objectIndex, second->angle08);
        func_80027AB8((GameActor *)second, 1, 1);
        func_8003945C(second->objectIndex,
                      (int)(second->resource24->animation).tracks[1]->loopIndex);
        func_80039DCC(second->objectIndex,0x6c);
        func_80039C5C(second->objectIndex, first->objectIndex);
        first->field2C = 0;
        func_8003CC88(first->angle08);
        first->field6C = 0;
        func_8003CC58(first->angle08);
        first->field70 = 0;
        func_80039514(first->objectIndex, first->angle08);
        break;
      }
      break;
    case 7:
      direction = func_8003CD4C(second->position[1] - first->position[1],
                            second->position[0] - first->position[0]);
      first->angle08 = (short)direction;
      second->field2C = 0;
      func_8003CC88(second->angle08);
      second->field6C = 0;
      func_8003CC58(second->angle08);
      second->field70 = 0;
      func_80039514(second->objectIndex, second->angle08);
      func_80027AB8((GameActor *)second, 1, 1);
      func_8003945C(second->objectIndex,
                    (int)(second->resource24->animation).tracks[0]->loopIndex);
      func_80039D4C(second->objectIndex, 1);
      func_80036B00(0xbe, second, 0);
      func_80027AB8((GameActor *)first, 3, 1);
      first->field2C = 0;
      func_8003CC88(first->angle08);
      first->field6C = 0;
      func_8003CC58(first->angle08);
      first->field70 = 0;
      func_80039514(first->objectIndex, first->angle08);
      func_80039D4C(first->objectIndex, 1);
      if (first->flags14 & 0x40) {
        first->flags14 &= ~0x40;
        first->callback44(first);
      }
      first->flags14 |= 0x40, first->callback44 = func_80029210, first->timer0E = 999;
      func_80039DCC(second->objectIndex,0x6e);
      func_80039C5C(second->objectIndex, first->objectIndex);
      break;
    case 8:
      direction = func_8003CD4C(second->position[1] - first->position[1],
                            second->position[0] - first->position[0]);
      angleDifference = func_8004CEF0((short)direction - first->angle08);
      if ((angleDifference & 0x7ff) < 0x259) {
        break;
      }
      direction = func_8003CD4C(second->position[1] - first->position[1],
                            second->position[0] - first->position[0]);
      first->angle08 = (short)direction;
      second->field2C = 0;
      func_8003CC88(second->angle08);
      second->field6C = 0;
      func_8003CC58(second->angle08);
      second->field70 = 0;
      func_80039514(second->objectIndex, second->angle08);
      func_80027AB8((GameActor *)second, 1, 1);
      func_8003945C(second->objectIndex,
                    (int)(second->resource24->animation).tracks[0]->loopIndex);
      func_80039DCC(second->objectIndex,0x6d);
      func_80039C5C(second->objectIndex, first->objectIndex);
      func_80039D4C(second->objectIndex, 1);
      break;

    }
  }
  return 0;
}

