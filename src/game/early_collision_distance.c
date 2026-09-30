#include "../../include/early_game_state.h"
#include "../../include/object_recovery.h"
#include "../../include/script_service_internal.h"

#include "../../include/early_collision_internal.h"

extern unsigned char D_8008FD90[];

int func_80015020(EarlyGameActor *first, EarlyGameActor *second,
                  int *firstPosition, int *secondPosition, int *distance)
{
    int value;
    int x;
    int y;

    x = firstPosition[0] - secondPosition[0];
    y = firstPosition[1] - secondPosition[1];
    value = func_8003CCE8(x * x + y * y) * 100;
    *distance = value;
    value /= ((CollisionDistanceResource *)first->resource24)->playbackSpeed +
             ((CollisionDistanceResource *)second->resource24)->playbackSpeed;
    func_8001C49C(D_8008FD90,
                 ((CollisionDistanceResource *)first->resource24)->value16,
                 ((CollisionDistanceResource *)second->resource24)->value16, value);
    return value;
}
