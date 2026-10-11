#include "../../../include/player_behavior_internal.h"

void func_80033974(ActorBehaviorActorInternal *actor,int unused)
{
  unsigned char idle;
  short shortValue;
  short shortAngle;
  int restorePosition;
  int initialRestore;
  ActorBehaviorActorInternal *child;
  int value;
  TextGlyphResource *resource;
  int *stickX;
  EarlyGameActor *projectile;
  unsigned int bits;
  unsigned int otherBits;
  int *position;
  int tentativeX;
  int *stickY;
  int temporary;
  int tentativeY;
  int previousX;
  int previousY;
  int previousZ;
  EarlyGamePosition projectilePosition;
  ActorBehaviorActorInternal *target;
  ActorBehaviorActorInternal *releasedChild;
  PlayerBehaviorInput *input;
  PlayerBehaviorState *player;
  int secondaryY;
  int secondaryX;
  unsigned int targetAngle;
  int projectileKind;
  int speed;
  int moveY;
  int moveX;
  int controller;
  int deathFrame;
  int searchIndex;
  D_800BEF6C = -1;
  secondaryX = 0;
  secondaryY = 0;
  target = (ActorBehaviorActorInternal *)0x0;
  initialRestore = 0;
  player = (PlayerBehaviorState *)actor->field3C;
  D_800BEF60 = actor;
  actor->flags14 = actor->flags14 | 0x2000;
  actor->position[2] = 500;
  if ((D_80073A40 != 0) &&
     (actor->flags14 = actor->flags14 | 0x400, 10000 < (unsigned int)(D_8009EFA0 - D_80097644))) {
    D_8007BB18 = 0;
    D_80073A40 = 0;
    actor->flags14 = actor->flags14 & 0xfffffbff;
    value = (int) player->actor0C;
    if (value != 0) {
      func_80039E5C((int)*(short *)(value + 0xc),1);
    }
  }
  if ((player == (PlayerBehaviorState *) (D_8009B190 + 1)) && ((D_8007C334 & 4) != 0)) {
    controller = 2;
  }
  else {
    controller = 0;
  }
  restorePosition = initialRestore;
  switch(actor->animation1F) {
  case '\x01':
    if ((D_800BA74C != -1) && (1000 < (unsigned int)(D_8009EFA0 - actor->field48))) {
      func_80027AB8((GameActor *) actor,8,1);
      bits = actor->flags14 & 0xffffffbf;
      actor->flags14 = bits;
      actor->flags14 = bits | 0x4000;
      actor->field48 = D_8009EFA0;
    }
    value = func_800393FC((int)actor->objectIndex);
    if (value == 0x6e) {
      value = func_80039CD0((int)actor->objectIndex);
      value = value * 0x100;
      if (value < 0) {
        value = value + 1;
      }
      value = actor->frame18 - (value >> 1);
      if (0 < value) {
        deathFrame = value;
        temporary = func_80039CD0((int)actor->objectIndex);
        value = actor->frame18;
        tentativeX = value << 4;
        if (value < 0) {
          value = value + 0xff;
        }
        func_8001C49C(D_80094218,value >> 8,0x1000 - tentativeX / temporary);
        value = func_80039CD0((int)actor->objectIndex);
        temporary = deathFrame << 5;
        func_800397E0((int)actor->objectIndex,
                      (float)((0x1000 - temporary / value) * actor->resource24->scale) / 40960.0f);
        shortValue = actor->objectIndex;
        actor->position[2] = -deathFrame;
        func_800290B0((int)shortValue,actor->position);
        value = func_80039CD0((int)actor->objectIndex);
        func_8003978C((int)actor->objectIndex,
                      (float)((temporary / value) * 2 * actor->resource24->scale + 0x1000) / 40960.0f);
      }
    }
    if (D_800AD138.saved.extra48 == 3) {
      restorePosition = 0;
      if ((unsigned int)(D_8009EFA0 - actor->field48) < 0x3e9) goto finish;
      value = player->active1C + -1;
      player->active1C = value;
      if (value < 1) {
        D_800AD138.saved.selection34 = (GamePlayerState *) player - D_8009B190;
        D_800AD138.saved.extra48 = 0;
        value = 0;
        if (0 < D_800AD138.saved.mode) {
          do {
            D_800AD138.saved.selection34 = D_800AD138.saved.selection34 + 1;
            if (D_800AD138.saved.mode <= D_800AD138.saved.selection34) {
              D_800AD138.saved.selection34 = 0;
            }
            D_800AD138.saved.currentPlayer =
                 D_800AD138.saved.playerChoices38[D_800AD138.saved.selection34];
            if (0 < D_8009B190[D_800AD138.saved.currentPlayer].saved.active) {
              searchIndex = value;
              func_8003B520(&D_800AD138,&D_8009B190[D_800AD138.saved.currentPlayer].saved.field34,0x28);
              value = searchIndex;
              break;
            }
            value = value + 1;
          } while (value < D_800AD138.saved.mode);
        }
        restorePosition = 0;
        if (value == D_800AD138.saved.mode) {
          func_80032F70();
          restorePosition = 0;
        }
        goto finish;
      }
      func_80027AB8((GameActor *) actor,8,1);
      bits = actor->flags14 & 0xffffffbf;
      actor->flags14 = bits;
      actor->flags14 = bits | 0x4000;
      actor->field48 = D_8009EFA0;
      restorePosition = initialRestore;
    }
    break;
  case '\0':
  case '\b':
    if (D_800AD288 == 3) {
      bits = actor->flags14;
      if ((bits & 0x4000) != 0) {
        value = (int) player->actor0C;
        otherBits = D_8009EFA0 - actor->field48;
        if (otherBits < 0x3e9) {
          if (value != 0) {
            bits = (otherBits * 300) / 1000;
            if (bits == 0) {
              bits = 1;
            }
            func_80039E5C((int)*(short *)(value + 0xc),otherBits / bits & 1);
          }
        }
        else {
          if (value != 0) {
            func_80039E5C((int)*(short *)(value + 0xc),1);
            bits = actor->flags14;
          }
          actor->flags14 = bits & 0xffffbfff;
        }
      }
      input = (PlayerBehaviorInput *) &player->input34;
      if (D_800AD138.saved.extra48 != 3) {
        input = (PlayerBehaviorInput *) &D_800AD138;
      }
      bits = input->input.pressed20 & 0xf;
      if (bits == 0) {
        player->charge9C =
             player->charge9C - D_8009EF94;
      }
      else {
        input->selection24 = bits;
        player->charge9C =
             player->charge9C + D_8009EF94 * 4;
      }
      value = player->charge9C;
      if ((1000 < value) && (child = D_800AA708, actor->countdown54 != 0)) {
        for (; child != (ActorBehaviorActorInternal *)0x0; child = child->next78) {
          if ((((child->kind1C == '\0') && (resource = child->resource24, resource->actorKind == '!')) &&
              (child->animation1F == '\x03')) &&
             (actor == (ActorBehaviorActorInternal *) child->field3C)) {
            child->angle08 = child->angle08 + 0x800U & 0xfff;
            shortValue = child->angle08;
            child->field2C = (int)*(short *)(resource->unknown16 + 2);
            releasedChild = child;
            value = func_8003CC88((int)shortValue);
            shortValue = releasedChild->angle08;
            value = value * *(short *)(releasedChild->resource24->unknown16 + 2);
            if (value < 0) {
              value = value + 0xfff;
            }
            releasedChild->field6C = value >> 0xc;
            value = func_8003CC58((int)shortValue);
            shortValue = releasedChild->objectIndex;
            shortAngle = releasedChild->angle08;
            value = value * *(short *)(releasedChild->resource24->unknown16 + 2);
            if (value < 0) {
              value = value + 0xfff;
            }
            releasedChild->field70 = value >> 0xc;
            func_80039514((int)shortValue,(int)shortAngle);
            func_80027AB8((GameActor *) releasedChild,0,1);
            releasedChild->countdown54 = D_8009EFA0;
            actor->countdown54 = actor->countdown54 + -1;
            value = player->charge9C;
            break;
          }
        }
        value = value + -500;
        player->charge9C = value;
      }
      if (value < 0) {
        player->charge9C = 0;
      }
      bits = input->input.pressed20;
      otherBits = bits & 0x1000;
      if (((bits & 0x800) != 0) && (otherBits = bits & 0x1000, player->selection70 != 0)) {
        func_800338F0(&player->selection70);
        otherBits = input->input.pressed20 & 0x1000;
      }
      if ((otherBits != 0) && (player->selection74 != 0)) {
        func_800338F0(&player->selection74);
      }
      temporary = D_800B6FD0 * 0x500;
      value = (player->value7C + 5) * actor->resource24->speed *
              player->blend80 * (D_800B6FD0 - actor->countdown54);
      speed = value / temporary + 1;
      if (D_800AD2F8.field08 == 0) {
        speed = (speed * 8) / 10;
      }
      moveY = 0;
      moveX = 0;
      if (D_800AD288 != 7) {
        if (D_800AD280 == 6) {
          target = (ActorBehaviorActorInternal *) func_800330F8(player,actor,&moveX,&moveY,speed);
        }
        else {
          value = controller * 4;
          if ((1 << (controller + 1U & 0x1f) & D_8007C334) != 0) {
            temporary = func_8004CEF0(D_8013DBB8[controller + 1]);
            if (0xf < temporary) {
              secondaryX = func_800338CC(D_8013DBB8[controller + 1] * 0x50,8);
            }
            temporary = func_8004CEF0(D_8013DBC8[controller + 1]);
            if (0xf < temporary) {
              secondaryY = func_800338CC(D_8013DBC8[controller + 1] * 0x50,8);
              secondaryY = -secondaryY;
            }
          }
          value = controller * 4;
          if ((input->input.flags00 & 1) == 0) {
            moveX = D_8013DBB8[controller];
            temporary = func_8004CEF0(moveX);
            if (temporary < 0xf) {
              moveX = 0;
            }
            moveY = D_8013DBC8[controller];
            value = func_8004CEF0(moveY);
            if (value < 0xf) {
              moveY = 0;
            }
            value = func_800338CC(moveY * 0x50,8);
            moveY = (value * -speed) / 0x16;
            value = func_800338CC(moveX * 0x50,8);
            moveX = (value * speed) / 0x16;
          }
          if ((moveX == 0) && (moveY == 0)) {
            bits = input->input.held1C;
            if ((bits & 4) != 0) {
              bits = input->input.held1C;
              moveY = -speed;
            }
            if ((bits & 8) != 0) {
              moveY = moveY + speed;
              bits = input->input.held1C;
            }
            if ((bits & 1) != 0) {
              moveX = -speed;
              bits = input->input.held1C;
            }
            if ((bits & 2) != 0) {
              moveX = moveX + speed;
            }
          }
        }
      }
      if (moveX != 0) {
        moveY = moveY * 0xd7;
        if (moveY < 0) {
          moveY = moveY + 0xff;
        }
        moveY = moveY >> 8;
      }
      if (moveY != 0) {
        moveX = moveX * 0xd7;
        if (moveX < 0) {
          moveX = moveX + 0xff;
        }
        moveX = moveX >> 8;
      }
      actor->field6C = moveX;
      actor->field70 = moveY;
      if ((moveX != 0) || (moveY != 0)) {
        value = func_8003CD4C(moveY,moveX);
        func_80039514((int)actor->objectIndex,value);
      }
      if (moveX == 0 && moveY == 0) {
        bits = D_8009EFA0 - player->timestamp94;
        player->timestamp98 = D_8009EFA0;
        if (bits < 0x65) {
          player->idle04 = '\0';
        }
        else {
          player->idle04 = '\x01';
        }
        bits = actor->flags14;
        if ((bits & 1) == 0) {
          actor->flags14 = bits | 1;
          func_80029194(actor);
        }
        else if ((((D_800AD288 == 3) && ((bits & 0x4400) == 0)) &&
                 (2000 < (unsigned int)(D_8009EFA0 - actor->field48))) &&
                ((input->input.held1C & 1) == 0)) {
          actor->field48 = D_8009EFA0;
          value = func_8004CDE8();
          bits = value >> 3 & 1;
          if ((value >> 3 < 0) && (bits != 0)) {
            bits = bits - 2;
          }
          func_8003B520(&(actor->resource24->animation).tracks[8]->field08,
                        D_800A4538 + 8 + bits * 0x10,8);
          bits = actor->flags14;
          if ((bits & 0x40) != 0) {
            actor->flags14 = bits & 0xffffffbf;
            (*actor->callback44)(actor);
            bits = actor->flags14;
          }
          actor->timer0E = 999;
          actor->flags14 = bits | 0x40;
          actor->callback44 = func_80029194;
          func_80027AB8((GameActor *) actor,8,0);
          func_8003945C((int)actor->objectIndex,
                        (int)(actor->resource24->animation).tracks[8]->loopIndex);
        }
      }
      else {
        if (moveX < 0) {
          bits = 0xffffffff;
        }
        else {
          bits = (unsigned int)(0 < moveX);
        }
        if (moveY < 0) {
          otherBits = 0xffffffff;
        }
        else {
          otherBits = (unsigned int)(0 < moveY);
        }
        player->direction88 = otherBits * 3 + bits + 4;
        if (D_8007394C == 0) {
          value = func_8003CD4C(moveY,moveX);
          actor->angle08 = (short)value;
        }
        func_80027AB8((GameActor *) actor,0,0);
        actor->flags14 = actor->flags14 & 0xfffffffe;
        idle = player->idle04;
        player->timestamp94 = D_8009EFA0;
        if ((idle == '\0') ||
           (bits = D_8009EFA0 - player->timestamp98, 99 < bits)) {
          player->blend80 = 256;
        }
        else {
          player->blend80 = (bits * 0x100) / 100;
        }
      }
      func_80035E3C(actor,speed,(EarlyPlayerInputState *)input);
      position = actor->position;
      previousX = *position;
      previousY = actor->position[1];
      previousZ = actor->position[2];
      tentativeY = actor->position[1];
      value = actor->unknown00[3] + -30000;
      temporary = 30000 - actor->unknown00[3];
      tentativeX = actor->position[0] + D_8009EF94 * actor->field6C;
      actor->position[0] = tentativeX;
      tentativeY = tentativeY + D_8009EF94 * actor->field70;
      actor->position[1] = tentativeY;
      if ((((tentativeX < value) || (temporary < tentativeX)) || (tentativeY < value)) || (temporary < tentativeY)) {
boundary:
        func_80017F9C(actor);
        restorePosition = 1;
      }
      else {
        if (D_800BA784 != 0) {
          value = func_8004CEF0(tentativeX);
          temporary = func_8004CEF0(actor->position[1]);
          if (42000 - actor->unknown00[3] < temporary + value) goto boundary;
        }
        value = actor->position[1];
        actor->position[0] = actor->position[0] - D_8009EF94 * actor->field6C;
        actor->position[1] = value - D_8009EF94 * actor->field70;
      }
      if (D_800AD288 == 3) {
        if (D_800AD280 == 9) {
          moveY = 0;
          moveX = 0;
          if ((input->input.flags00 & 1) != 0) {
            stickX = &D_8013DBB8[controller];
            stickY = &D_8013DBC8[controller];
            value = func_8004CEF0(*stickX);
            if ((10 < value) || (value = func_8004CEF0(*stickY), 10 < value)) {
              value = func_8004CEF0(*stickX);
              if (10 < value) {
                moveX = func_800338CC(*stickX * 0x50,8);
              }
              value = func_8004CEF0(*stickY);
              if (10 < value) {
                moveY = func_800338CC(*stickY * 0x50,8);
                moveY = -moveY;
              }
              goto aim_ready;
            }
          }
          if ((input->input.held1C & 0xf0) == 0) {
            moveX = secondaryX;
            moveY = secondaryY;
          }
          else {
            moveY = 0;
            moveX = 0;
            bits = input->input.held1C;
            if ((bits & 0x40) != 0) {
              moveY = -0x100;
              bits = input->input.held1C;
            }
            if ((bits & 0x80) != 0) {
              moveY = moveY + 0x100;
              bits = input->input.held1C;
            }
            if ((bits & 0x10) != 0) {
              moveX = -0x100;
              bits = input->input.held1C;
            }
            if ((bits & 0x20) != 0) {
              moveX = moveX + 0x100;
            }
          }
        }
        else if ((D_800AD280 == 6) && (target != (ActorBehaviorActorInternal *)0x0)) {
          temporary = target->position[0] - actor->position[0];
          value = temporary;
          if (temporary < 0) {
            value = temporary + 0x1f;
          }
          tentativeY = target->position[1] - actor->position[1];
          tentativeX = tentativeY;
          if (tentativeY < 0) {
            tentativeX = tentativeY + 0x1f;
          }
          if ((value >> 5) * (value >> 5) + (tentativeX >> 5) * (tentativeX >> 5) < 0x1e2a04) {
            value = func_8003CD4C(tentativeY,temporary);
            targetAngle = value + 0x100U & 0xe00;
            moveX = func_8003CC88(targetAngle);
            moveY = func_8003CC58(targetAngle);
          }
        }
      }
aim_ready:
      if (moveX == 0 && moveY == 0) {
        player->direction84 = 4;
      }
      else {
        value = player->selection6C;
        if (value == 3) {
          projectileKind = 1;
        }
        else if (value == 4) {
          projectileKind = 2;
        }
        else {
          projectileKind = 0;
        }
        if (moveX < 0) {
          bits = 0xffffffff;
        }
        else {
          bits = (unsigned int)(0 < moveX);
        }
        if (moveY < 0) {
          otherBits = 0xffffffff;
        }
        else {
          otherBits = (unsigned int)(0 < moveY);
        }
        D_800BEF6C = func_8003CD4C(moveY,moveX);
        if (((unsigned int)(int)*(short *)(D_800AC998[projectileKind].unknown0C + 4) <
             (unsigned int)(D_8009EFA0 - player->timestamp8C)) ||
           (otherBits * 3 + bits + 4 != player->direction84)) {
          player->direction84 = otherBits * 3 + bits + 4;
          value = player->selection6C;
          player->timestamp8C = D_8009EFA0;
          if ((value != -1) &&
             (temporary = player->count78, value = D_8009AA00[value].value58,
             player->count78 = temporary + 1, value < temporary)) {
            player->selection6C = -1;
          }
          D_800BEF6C = func_80036064((GameActor *) actor,D_800BEF6C);
          switch(player->selection6C) {
          case 0:
            func_80038D8C((EarlyGamePosition *)position,projectileKind,
                          (ActorBehaviorPlayerInternal *)player,D_800BEF6C);
            func_80038D8C((EarlyGamePosition *)position,projectileKind,
                          (ActorBehaviorPlayerInternal *)player,D_800BEF6C + 0x800U & 0xfff);
            func_8003614C(100,0,1,0);
            break;
          case 1:
            func_80038D8C((EarlyGamePosition *)position,projectileKind,
                          (ActorBehaviorPlayerInternal *)player,D_800BEF6C);
            func_80038D8C((EarlyGamePosition *)position,projectileKind,
                          (ActorBehaviorPlayerInternal *)player,D_800BEF6C + 0x200U & 0xfff);
            func_80038D8C((EarlyGamePosition *)position,projectileKind,
                          (ActorBehaviorPlayerInternal *)player,D_800BEF6C - 0x200U & 0xfff);
            func_8003614C(0x65,0,1,0);
            break;
          case 2:
            func_80038D8C((EarlyGamePosition *)position,projectileKind,
                          (ActorBehaviorPlayerInternal *)player,D_800BEF6C);
            func_80038D8C((EarlyGamePosition *)position,3,(ActorBehaviorPlayerInternal *)player,
                          D_800BEF6C + 0x800U & 0xfff);
            func_80038D8C((EarlyGamePosition *)position,projectileKind,
                          (ActorBehaviorPlayerInternal *)player,D_800BEF6C + 0x200U & 0xfff);
            func_80038D8C((EarlyGamePosition *)position,projectileKind,
                          (ActorBehaviorPlayerInternal *)player,D_800BEF6C - 0x200U & 0xfff);
            func_8003614C(0x66,0,1,0);
            break;
          case 3:
            func_8003614C(0x69,0,1,0);
            projectile = func_80038D8C((EarlyGamePosition *)position,projectileKind,
                                    (ActorBehaviorPlayerInternal *)player,D_800BEF6C);
            projectilePosition.value[2] = actor->position[2];
            value = D_8009EF94 * projectile->field6C;
            if (value < 0) {
              value = value + 1;
            }
            projectilePosition.value[0] = *position + (value >> 1);
            value = D_8009EF94 * projectile->field70;
            if (value < 0) {
              value = value + 1;
            }
            projectilePosition.value[1] = actor->position[1] + (value >> 1);
            func_80038D8C(&projectilePosition,projectileKind,(ActorBehaviorPlayerInternal *)player,D_800BEF6C);
            break;
          case 4:
            func_8003614C(0x69,0,1,0);
            func_80038D8C((EarlyGamePosition *)position,projectileKind,
                          (ActorBehaviorPlayerInternal *)player,D_800BEF6C);
            break;
          case -1:
          default:
            func_80038D8C((EarlyGamePosition *)position,projectileKind,
                          (ActorBehaviorPlayerInternal *)player,D_800BEF6C);
            func_8003614C(6,0,1,0);
          }
          goto finish;
        }
      }
    }
    else {
      actor->field74 = 0;
      actor->field70 = 0;
      actor->field6C = 0;
    }
    break;
  case '\x02':
  case '\x03':
  case '\x04':
  case '\x05':
  case '\x06':
  case '\x07':
  case '\x09':
  default:
    break;
  }
finish:
  if (restorePosition) {
    actor->position[0] = previousX;
    actor->position[1] = previousY;
    actor->position[2] = previousZ;
  }
  D_800BEF64 = (int)actor->angle08;
  return;
}
