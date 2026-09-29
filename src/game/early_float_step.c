#include "../../include/early_game_state.h"

float func_80012690(float target, float current, float maximumStep)
{
    float delta;
    float direction;
    float step;

    delta = target - current;
    direction = 1.0f;
    step = delta;
    if (target < current) {
        direction = -1.0f;
        step = -delta;
    }
    if (maximumStep < step) {
        step = maximumStep;
    }
    return direction * step + current;
}
