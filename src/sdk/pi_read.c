#include "../../include/pi.h"

extern int osPiRawReadIo(unsigned int deviceAddress, unsigned int *word);

int func_80063560(unsigned int deviceAddress, unsigned int *word)
{
    register int result;

    func_80067820();
    result = osPiRawReadIo(deviceAddress, word);
    func_80067864();
    return result;
}
