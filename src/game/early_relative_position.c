#include "../../include/early_game_state.h"
#include "../../include/fixed_math.h"
void func_8000CD50(EarlyGameActor *source, EarlyGameActor *destination,
                   int firstScale, int secondScale, int yOffset, int mode)
{
    int secondCosine;
    int secondSine;
    int firstCosine;
    int firstSine;
    int angle;
    int direction;

    angle = source->field4C;
    direction = angle * 16;
    secondCosine = func_8004DBE4(secondScale, direction);
    secondSine = func_8004DBB0(secondScale, direction);
    firstCosine = func_8004DBE4(firstScale, direction);
    firstSine = func_8004DBB0(firstScale, direction);
    if (mode == 1) destination->field4C = angle;
    destination->field54 = secondCosine - firstSine + source->field54;
    if (mode != 2) destination->field58 = source->field58 + yOffset;
    destination->field5C = secondSine + firstCosine + source->field5C;
}
