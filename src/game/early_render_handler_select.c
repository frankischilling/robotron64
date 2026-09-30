#include "../../include/early_game_helpers.h"

EarlyRenderHandler func_8000CE34(int selection)
{
    EarlyRenderHandler handler = func_8000B99C;

    if (selection < 0) {
        selection = 0;
    }
    if (selection > 4) {
        selection = 4;
    }
    switch (selection) {
    case 0:
        return func_8000B99C;
    case 1:
        return func_8000B964;
    case 2:
        return func_8000BEC0;
    case 3:
        return func_8000BE80;
    case 4:
        return func_8000BEA0;
    }
    return handler;
}
