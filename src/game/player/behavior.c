#include "../../../include/player_behavior_internal.h"

void func_80033974(ActorBehaviorActorInternal *actor, int unused) {
    unsigned int bits;
    unsigned int otherBits;
    int searchCount;
    int deathFrame;
    int controller;
    ActorBehaviorActorInternal *displayActor;
    int moveX;
    int moveY;
    int speed;
    int projectileKind;
    int value;
    int *stickX;
    int secondaryX;
    int secondaryY;
    PlayerBehaviorState *player;
    PlayerBehaviorInput *input;
    EarlyGameActor *projectile;
    ActorBehaviorActorInternal *child;
    GameActor *target;
    EarlyGamePosition projectilePosition;
    EarlyGamePosition previousPosition;
    int restorePosition;
    EarlyGamePosition *position;
    int *stickY;
    int searchMode;
    int directionX;
    int directionY;

    D_800BEF6C = -1;
    secondaryX = 0;
    secondaryY = 0;
    target = (GameActor *)0;
    restorePosition = 0;
    D_800BEF60 = actor;
    actor->flags14 |= 0x2000;
    player = (PlayerBehaviorState *)actor->field3C;
    actor->position[2] = 0x1F4;
    if (D_80073A40 != 0) {
        actor->flags14 |= 0x400;
        if ((unsigned int) (D_8009EFA0 - D_80097644) >= 0x2711U) {
            D_8007BB18 = 0;
            D_80073A40 = 0;
            actor->flags14 &= ~0x400;
            displayActor = player->actor0C;
            if (displayActor != 0) {
                func_80039E5C((int) displayActor->objectIndex, 1);
            }
        }
    }
    if ((player == (PlayerBehaviorState *)&D_8009B190[1]) && (D_8007C334 & 4)) {
        controller = 2;
    } else {
        controller = 0;
    }
    switch (actor->animation1F) {
    case 1:
        if ((D_800BA74C != -1) && ((unsigned int) (D_8009EFA0 - actor->field48) >= 0x3E9U)) {
            func_80027AB8((GameActor *) actor, 8U, 1);
            actor->flags14 &= ~0x40;
            actor->flags14 |= 0x4000;
            actor->field48 = D_8009EFA0;
        }
        if (func_800393FC((int) actor->objectIndex) == 0x6E) {
            deathFrame = actor->frame18 - ((int) (func_80039CD0((int) actor->objectIndex) << 8) / 2);
            if (deathFrame > 0) {
                func_8001C49C(D_80094218, actor->frame18 / 256, 0x1000 - ((int) (actor->frame18 * 0x10) / func_80039CD0((int) actor->objectIndex)));
                value = (deathFrame << 5) / func_80039CD0((int) actor->objectIndex);
                func_800397E0((int) actor->objectIndex, (float) ((0x1000 - value) * actor->resource24->scale) / 40960.0f);
                actor->position[2] = -deathFrame;
                func_800290B0((int) actor->objectIndex, actor->position);
                func_8003978C((int) actor->objectIndex, (float) ((((deathFrame << 5) / func_80039CD0((int) actor->objectIndex)) * 2 * actor->resource24->scale) + 0x1000) / 40960.0f);
            }
        }
        if (D_800AD138.saved.extra48 == 3) {
            if ((unsigned int) (D_8009EFA0 - actor->field48) >= 0x3E9U) {
                if (--player->active1C > 0) {
                    func_80027AB8((GameActor *) actor, 8U, 1);
                    actor->flags14 &= ~0x40;
                    actor->flags14 |= 0x4000;
                    actor->field48 = D_8009EFA0;
                } else {
                    D_800AD138.saved.extra48 = 0;
                    D_800AD138.saved.selection34 = (GamePlayerState *)player - D_8009B190;
                    searchCount = 0;
                    for (; searchCount < D_800AD138.saved.mode; searchCount += 1) {
                        D_800AD138.saved.selection34 += 1;
                        if (D_800AD138.saved.selection34 >= D_800AD138.saved.mode) {
                            D_800AD138.saved.selection34 = 0;
                        }
                        D_800AD138.saved.currentPlayer = D_800AD138.saved.playerChoices38[D_800AD138.saved.selection34];
                        if (D_8009B190[D_800AD138.saved.currentPlayer].saved.active > 0) {
                            func_8003B520(&D_800AD138, &D_8009B190[D_800AD138.saved.currentPlayer].saved.field34, 0x28);
                            break;
                        }
                    }
                    searchMode = D_800AD138.saved.mode;
                    if (searchCount == searchMode) {
                        func_80032F70();
                    }
                }
            }
        }
        break;
    default:
    case 2:
    case 3:
    case 4:
    case 5:
    case 6:
    case 7:
    case 9:
        break;
    case 0:
    case 8:
        if (D_800AD288 == 3) {
            if (actor->flags14 & 0x4000) {
                displayActor = player->actor0C;
                bits = D_8009EFA0 - actor->field48;
                if (bits >= 0x3E9U) {
                    if (displayActor != 0) {
                        func_80039E5C((int) displayActor->objectIndex, 1);
                    }
                    actor->flags14 &= ~0x4000;
                } else if (displayActor != 0) {
                    otherBits = (unsigned int) (bits * 0x12C) / 1000U;
                    if ((int) otherBits <= 0) {
                        otherBits = 1;
                    }
                    func_80039E5C((int) displayActor->objectIndex, (bits / otherBits) & 1);
                }
            }
            if (D_800AD138.saved.extra48 == 3) {
                input = (PlayerBehaviorInput *)&player->input34;
            } else {
                input = (PlayerBehaviorInput *)&D_800AD138;
            }
            bits = input->input.pressed20 & 0xF;
            if (bits != 0) {
                input->selection24 = bits;
                player->charge9C = (int) (player->charge9C + (D_8009EF94 * 4));
            } else {
                player->charge9C = (int) (player->charge9C - D_8009EF94);
            }
            value = player->charge9C;
            if ((value >= 0x3E9) && (actor->countdown54 != 0)) {
                child = D_800AA708;
                if (child != 0) {
loop_49:
                    if ((child->kind1C == 0) && (child->resource24->actorKind == 0x21) && (child->animation1F == 3) && (actor == (ActorBehaviorActorInternal *)child->field3C)) {
                        child->angle08 = (child->angle08 + 0x800) & 0xFFF;
                        child->field2C = (int) (*(short *)(child->resource24->unknown16 + 2));
                        child->field6C = (int) (func_8003CC88((int) child->angle08) * (*(short *)(child->resource24->unknown16 + 2))) / 4096;
                        child->field70 = (int) (func_8003CC58((int) child->angle08) * (*(short *)(child->resource24->unknown16 + 2))) / 4096;
                        func_80039514((int) child->objectIndex, (int) child->angle08);
                        func_80027AB8((GameActor *)child, 0U, 1);
                        child->countdown54 = D_8009EFA0;
                        actor->countdown54 -= 1;
                        value = player->charge9C;
                    } else {
                        child = child->next78;
                        if (child != 0) {
                            goto loop_49;
                        }
                    }
                }
                value = value - 0x1F4;
                player->charge9C = value;
            }
            if (value < 0) {
                player->charge9C = 0;
            }
            bits = input->input.pressed20;
            otherBits = bits & 0x1000;
            if (bits & 0x800) {
                otherBits = bits & 0x1000;
                if (player->selection70 != 0) {
                    func_800338F0(&player->selection70, (ScenePlayerRuntime *)player);
                    otherBits = input->input.pressed20 & 0x1000;
                }
            }
            if ((otherBits != 0) && (player->selection74 != 0)) {
                func_800338F0(&player->selection74, (ScenePlayerRuntime *)player);
            }
            speed = ((int) ((player->value7C + 5) * actor->resource24->speed * player->blend80 * (D_800B6FD0 - actor->countdown54)) / (int) (D_800B6FD0 * 0x500)) + 1;
            if (D_800AD2F8.field08 == 0) {
                speed = (int) (speed * 8) / 10;
            }
            moveY = 0;
            moveX = 0;
            if (D_800AD288 != 7) {
                if (D_800AD280 != 6) {
                    if ((1 << (controller + 1)) & D_8007C334) {
                        stickX = &D_8013DBB8[controller];
                        if (func_8004CEF0(stickX[1]) >= 0x10) {
                            secondaryX = func_800338CC(stickX[1] * 0x50, 8);
                        }
                        stickY = &D_8013DBC8[controller];
                        if (func_8004CEF0(stickY[1]) >= 0x10) {
                            secondaryY = -func_800338CC(stickY[1] * 0x50, 8);
                        }
                    }
                    if (!(input->input.flags00 & 1)) {
                        moveX = D_8013DBB8[controller];
                        stickY = &D_8013DBC8[controller];
                        if (func_8004CEF0(moveX) < 0xF) {
                            moveX = 0;
                        }
                        moveY = stickY[0];
                        if (func_8004CEF0(moveY) < 0xF) {
                            moveY = 0;
                        }
                        moveY = (int) (func_800338CC(moveY * 0x50, 8) * -speed) / 22;
                        moveX = (int) (func_800338CC(moveX * 0x50, 8) * speed) / 22;
                    }
                    if ((moveX == 0) && (moveY == 0)) {
                        if (input->input.held1C & 4) {
                            moveY -= speed;
                        }
                        if (input->input.held1C & 8) {
                            moveY += speed;
                        }
                        if (input->input.held1C & 1) {
                            moveX -= speed;
                        }
                        if (input->input.held1C & 2) {
                            moveX += speed;
                        }
                    }
                } else {
                    target = func_800330F8((GamePlayerState *) player, actor, &moveX, &moveY, speed);
                }
            }
            if (moveX != 0) {
                moveY = (int) (moveY * 0xD7) / 256;
            }
            if (moveY != 0) {
                moveX = (int) (moveX * 0xD7) / 256;
            }
            actor->field6C = moveX;
            actor->field70 = moveY;
            if (moveX != 0 || moveY != 0) {
                func_80039514((int) actor->objectIndex, func_8003CD4C(moveY, moveX));
            }
            if ((moveX | moveY) != 0) {
                directionX = moveX < 0 ? -1 : moveX > 0 ? 1 : 0;
                directionY = moveY < 0 ? -1 : moveY > 0 ? 1 : 0;
                player->direction88 = (int) ((directionY * 3) + directionX + 4);
                if (D_8007394C == 0) {
                    actor->angle08 = func_8003CD4C(moveY, moveX);
                }
                func_80027AB8((GameActor *) actor, 0U, 0);
                actor->flags14 &= ~1;
                player->timestamp94 = (int) D_8009EFA0;
                if ((player->idle04 != 0) && (bits = D_8009EFA0 - player->timestamp98, ((bits < 0x64U) != 0))) {
                    player->blend80 = (unsigned int) ((unsigned int) (bits << 8) / 100U);
                } else {
                    player->blend80 = 0x100U;
                }
            } else {
                player->timestamp98 = (int) D_8009EFA0;
                if ((unsigned int) (D_8009EFA0 - player->timestamp94) >= 0x65U) {
                    player->idle04 = 1U;
                } else {
                    player->idle04 = 0U;
                }
                bits = actor->flags14;
                if (!(bits & 1)) {
                    actor->flags14 = bits | 1;
                    func_80029194(actor);
                } else if (D_800AD288 == 3) {
                    if (!(bits & 0x4400)) {
                        if (((unsigned int) (D_8009EFA0 - actor->field48) >= 0x7D1U) && !(input->input.held1C & 1)) {
                            actor->field48 = D_8009EFA0;
                            func_8003B520(&actor->resource24->animation.tracks[8]->field08, (((int) (func_8004CDE8() >> 3) % 2) * 0x10) + 8 + D_800A4538, 8);
                            bits = actor->flags14;
                            if (bits & 0x40) {
                                actor->flags14 = bits & ~0x40;
                                actor->callback44(actor);
                            }
                            actor->timer0E = 0x3E7;
                            actor->flags14 |= 0x40;
                            actor->callback44 = func_80029194;
                            func_80027AB8((GameActor *) actor, 8U, 0);
                            func_8003945C((int) actor->objectIndex, (int) actor->resource24->animation.tracks[8]->loopIndex);
                        }
                    }
                }
            }
            func_80035E3C(actor, speed, (EarlyPlayerInputState *) input);
            position = (EarlyGamePosition *)actor->position;
            previousPosition = *position;
            searchCount = actor->unknown00[3] - 0x7530;
            searchMode = 0x7530 - actor->unknown00[3];
            value = actor->position[0] + (D_8009EF94 * actor->field6C);
            actor->position[0] = value;
            directionY = actor->position[1] + (D_8009EF94 * actor->field70);
            actor->position[1] = directionY;
            if ((value < searchCount) || (searchMode < value) || (directionY < searchCount) || (searchMode < directionY) || ((D_800BA784 != 0) && (value = func_8004CEF0(value), (((0xA410 - actor->unknown00[3]) < (func_8004CEF0(actor->position[1]) + value)) != 0)))) {
                func_80017F9C(actor);
                restorePosition = 1;
            } else {
                actor->position[0] -= D_8009EF94 * actor->field6C;
                actor->position[1] -= D_8009EF94 * actor->field70;
            }
            if (D_800AD288 == 3) {
                if (D_800AD280 == 9) {
                    moveY = 0;
                    moveX = 0;
                    if (input->input.flags00 & 1) {
                        stickX = &D_8013DBB8[controller];
                        stickY = &D_8013DBC8[controller];
                        if (func_8004CEF0(*stickX) < 0xB) {
                            if (func_8004CEF0(stickY[0]) >= 0xB) {
                                goto block_146;
                            }
                            goto block_151;
                        }
block_146:
                        if (func_8004CEF0(stickX[0]) >= 0xB) {
                            moveX = func_800338CC(stickX[0] * 0x50, 8);
                        }
                        if (func_8004CEF0(stickY[0]) >= 0xB) {
                            moveY = -func_800338CC(stickY[0] * 0x50, 8);
                        }
                    } else {
block_151:
                        if (input->input.held1C & 0xF0) {
                            moveY = 0;
                            moveX = 0;
                            if (input->input.held1C & 0x40) {
                                moveY = -0x100;
                            }
                            if (input->input.held1C & 0x80) {
                                moveY += 0x100;
                            }
                            if (input->input.held1C & 0x10) {
                                moveX = -0x100;
                            }
                            if (input->input.held1C & 0x20) {
                                moveX += 0x100;
                            }
                        } else {
                            moveX = secondaryX;
                            moveY = secondaryY;
                        }
                    }
                } else if ((D_800AD280 == 6) && (target != 0)) {
                    directionX = target->position[0] - actor->position[0];
                    searchMode = directionX / 32;
                    directionY = target->position[1] - actor->position[1];
                    searchCount = directionY / 32;
                    if (((searchMode * searchMode) + (searchCount * searchCount)) < 0x1E2A04) {
                        value = (func_8003CD4C(directionY, directionX) + 0x100) & 0xE00;
                        moveX = func_8003CC88(value);
                        moveY = func_8003CC58(value);
                    }
                }
            }
            if ((moveX | moveY) != 0) {
                if (player->selection6C != 3) {
                    if (player->selection6C != 4) {
                        projectileKind = 0;
                    } else {
                        projectileKind = 2;
                    }
                } else {
                    projectileKind = 1;
                }
                directionX = moveX < 0 ? -1 : moveX > 0 ? 1 : 0;
                directionY = moveY < 0 ? -1 : moveY > 0 ? 1 : 0;
                D_800BEF6C = func_8003CD4C(moveY, moveX);
                if (((unsigned int) (int)*(short *)(D_800AC998[projectileKind].unknown0C + 4) < (unsigned int) (D_8009EFA0 - player->timestamp8C)) || (((directionY * 3) + directionX + 4) != player->direction84)) {
                    player->direction84 = (int) ((directionY * 3) + directionX + 4);
                    value = player->selection6C;
                    player->timestamp8C = (int) D_8009EFA0;
                    if (value != -1) {
                        if (D_8009AA00[value].value58 < player->count78++) {
                            player->selection6C = -1;
                        }
                    }
                    D_800BEF6C = func_80036064((GameActor *) actor, D_800BEF6C);
                    switch (player->selection6C) {
                    case -1:
                    default:
                        func_80038D8C(position, projectileKind, (ActorBehaviorPlayerInternal *) player, D_800BEF6C, 185);
                        func_8003614C(6, 0, 1, 0);
                        break;
                    case 0:
                        func_80038D8C(position, projectileKind, (ActorBehaviorPlayerInternal *) player, D_800BEF6C, 185);
                        func_80038D8C(position, projectileKind, (ActorBehaviorPlayerInternal *) player, (D_800BEF6C + 0x800) & 0xFFF, 185);
                        func_8003614C(0x64, 0, 1, 0);
                        break;
                    case 1:
                        func_80038D8C(position, projectileKind, (ActorBehaviorPlayerInternal *) player, D_800BEF6C, 185);
                        func_80038D8C(position, projectileKind, (ActorBehaviorPlayerInternal *) player, (D_800BEF6C + 0x200) & 0xFFF, -1);
                        func_80038D8C(position, projectileKind, (ActorBehaviorPlayerInternal *) player, (D_800BEF6C - 0x200) & 0xFFF, -1);
                        func_8003614C(0x65, 0, 1, 0);
                        break;
                    case 2:
                        func_80038D8C(position, projectileKind, (ActorBehaviorPlayerInternal *) player, D_800BEF6C, 185);
                        func_80038D8C(position, 3, (ActorBehaviorPlayerInternal *) player, (D_800BEF6C + 0x800) & 0xFFF, -1);
                        func_80038D8C(position, projectileKind, (ActorBehaviorPlayerInternal *) player, (D_800BEF6C + 0x200) & 0xFFF, -1);
                        func_80038D8C(position, projectileKind, (ActorBehaviorPlayerInternal *) player, (D_800BEF6C - 0x200) & 0xFFF, -1);
                        func_8003614C(0x66, 0, 1, 0);
                        break;
                    case 4:
                        func_8003614C(0x69, 0, 1, 0);
                        func_80038D8C(position, projectileKind, (ActorBehaviorPlayerInternal *) player, D_800BEF6C, -1);
                        break;
                    case 3:
                        func_8003614C(0x69, 0, 1, 0);
                        projectile = func_80038D8C(position, projectileKind, (ActorBehaviorPlayerInternal *) player, D_800BEF6C, -1);
                        projectilePosition = *position;
                        projectilePosition.value[0] += (int) (D_8009EF94 * projectile->field6C) / 2;
                        projectilePosition.value[1] += (int) (D_8009EF94 * projectile->field70) / 2;
                        func_80038D8C((EarlyGamePosition *) &projectilePosition, projectileKind, (ActorBehaviorPlayerInternal *) player, D_800BEF6C, -1);
                        break;
                    }
                }
            } else {
                player->direction84 = 4;
            }
        } else {
            actor->field74 = 0;
            actor->field70 = 0;
            actor->field6C = 0;
        }
        break;
    }
    if (restorePosition != 0) {
        *(EarlyGamePosition *)actor->position = previousPosition;
    }
    D_800BEF64 = (int) actor->angle08;
}
