#include "../../include/object_recovery.h"
#include "../../include/fixed_math.h"

/* These older call sites pass an unmasked word. The SDK narrows it on entry;
 * a narrow prototype here adds caller instructions absent from the target.
 * See docs/sdk-math.md for the recovered calling convention. */
int func_8005FBB0(int angle);
int func_8005FC20(int angle);

int func_8003CC58(int angle)
{
    return func_8005FBB0(angle << 4) / 8;
}

int func_8003CC88(int angle)
{
    return func_8005FC20(angle << 4) / 8;
}

int func_8003CCB8(int angle)
{
    return func_8004DC18(angle) / 8;
}
