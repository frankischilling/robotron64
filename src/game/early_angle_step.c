#include "../../include/early_game_helpers.h"
#include "../../include/scalar_math.h"

int func_8000DF30(int target, int current, int maximum)
{
    int distance;

    target = func_8000DF14(target - current);
    distance = func_8004CEF0(target);
    if (maximum < distance) distance = maximum;
    current = (target < 0 ? -1 : target > 0 ? 1 : 0) * distance + current;
    return current;
}
