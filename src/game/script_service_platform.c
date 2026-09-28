#include "../../include/platform_services.h"
#include "../../include/script_service_internal.h"

typedef struct ScriptServicePoint {
    int x;
    int y;
    int unknown08;
} ScriptServicePoint;

void func_8001CDA0(int left, int top, int right, int bottom, int value)
{
    ScriptServicePoint first;
    ScriptServicePoint second;

    first.x = top;
    first.y = left;
    second.x = top;
    second.y = right;
    func_8003C60C(&first, &second, value, 0, 0);

    first.x = bottom;
    first.y = right;
    func_8003C60C(&second, &first, value, 0, 0);

    second.x = bottom;
    second.y = left;
    func_8003C60C(&first, &second, value, 0, 0);

    first.x = top;
    first.y = left;
    func_8003C60C(&first, &second, value, 0, 0);
}

void func_8001CE68(void)
{
}
