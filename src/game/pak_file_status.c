#include "../../include/pak_file.h"
#include "../../include/controller_services.h"

int func_8004C378(void)
{
    int status;

    status = func_8004F6B4();
    func_8001C49C(D_800955F0, status);
    return status;
}
