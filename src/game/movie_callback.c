#include "../../include/movie.h"
#include "../../include/movie_literals.h"
#include "../../include/text.h"

void func_8000440C(void (*handler)(int), int frame)
{
    if (D_800B14A8->callbackCount == MOVIE_CALLBACK_COUNT) {
        func_8001C0D0(D_8008F8F8);
    }
    D_800B14A8->callbacks[D_800B14A8->callbackCount].handler = handler;
    D_800B14A8->callbacks[D_800B14A8->callbackCount].frame = frame;
    D_800B14A8->callbackCount++;
}
