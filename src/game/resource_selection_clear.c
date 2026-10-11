#include "../../include/scene_action_internal.h"
#include "../../include/player_selection_internal.h"

void func_800338F0(int *selection, ScenePlayerRuntime *player)
{
    int first;
    int second;
    int third;

    first = 12, second = 13, third = 0;
    switch (*selection) {
    case 10:
        func_8001B8D8(&third, player);
        break;
    case 8:
        func_8001B8D8(&first, player);
        break;
    case 9:
        func_8001B8D8(&second, player);
        break;
    }
    *selection = 0;
}
