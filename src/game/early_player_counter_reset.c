typedef struct EarlyPlayerCounters {
    short values[14];
    short timers[14];
} EarlyPlayerCounters;

extern EarlyPlayerCounters D_8009E9E0;

void func_8001BF48(int *state)
{
    int index;

    state[6] = -1;
    for (index = 0; index < 14; index++) {
        D_8009E9E0.values[index] = -1;
        D_8009E9E0.timers[index] = 0;
    }
}
