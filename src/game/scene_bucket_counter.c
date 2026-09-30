#include "../../include/save_game.h"
#include "../../include/scene_counter_internal.h"

int func_80037144(int amount, SceneBucketCounter *counter)
{
    int oldValue;
    int newValue;
    int oldBucket;
    int bucketDelta;

    oldValue = counter->value18;
    newValue = amount;
    newValue = oldValue + newValue;
    oldBucket = oldValue / D_800AD2F8.field10;
    counter->value18 = newValue;

    if (D_800AD2F8.field10 != 55000) {
        bucketDelta = counter->value18 / D_800AD2F8.field10 - oldBucket;
        if (bucketDelta != 0) {
            func_80037050(bucketDelta, counter);
        }
    }

    return counter->value18;
}
