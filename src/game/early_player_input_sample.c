#include "../../include/static_menu_internal.h"
#include "../../include/early_input_internal.h"

extern void *D_800AEE9C;
extern unsigned char D_800773C4[];

void func_8001A1F0(GameSessionState *session)
{
    EarlyPlayerInputState *state = (EarlyPlayerInputState *)session;
    int mode = D_800AEE9C == 0;
    EarlyPlayerInputState *input;

    input = state;
    if (mode != 0) {
        mode = (state->flags00 & 1) != 0;
    }
    state->buttons10 = func_8003C1A8(state->port04, mode);
    if (D_800AEE9C != 0 && D_800AEE9C != D_8007751C &&
        D_800AEE9C != D_800773C4) {
        state->buttons10 |= func_8003C1A8((state->port04 + 2) & 3, 0);
    }
    state->pressed0C = state->buttons10 & ~state->previous14;
    state->pressed20 = input->pressed0C;
    state->previous14 = state->buttons10;
    state->held1C = state->buttons10;
    func_8001BFB0(state);
}
