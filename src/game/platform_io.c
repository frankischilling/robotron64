#include "../../include/platform_services.h"
#include "../../include/object_runtime.h"
#include "../../include/heap.h"
#include "../../include/rom_files.h"

void func_8003C5C4(void)
{
}

void func_8003C5CC()
{
}

void func_8003C5D4(void)
{
}

void func_8003C5DC(void)
{
}

int func_8003C5E4(void)
{
}

void func_8003C5EC(void)
{
}

void func_8003C5F4(void)
{
}

void func_8003C5FC(void)
{
}

void func_8003C604(void)
{
}

void func_8003C60C(void)
{
}

void func_8003C614(void)
{
}

void func_8003C61C(void)
{
}

void func_8003C624(void)
{
    func_8003A8B0();
}

void func_8003C644(void)
{
}

void *func_8003C64C(unsigned char *name, int *size)
{
    void *allocation;

    *size = func_8004EF6C(name);
    allocation = func_8004DD6C(*size);
    func_8004EE9C(name, allocation);
    return allocation;
}

void func_8003C690(void)
{
}

void func_8003C698(void *allocation)
{
    func_8004DC70(allocation);
}
