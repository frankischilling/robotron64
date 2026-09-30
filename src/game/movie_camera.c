#include "../../include/movie.h"

extern int D_800AD280;
void func_8003A070(float x, float y, float z);
void func_8003A128(int pitch, int yaw, int roll);

void func_80003ECC(int frame, int index)
{
    int pitch;
    int yaw;
    int roll;
    {
        MovieTrackState *track = &D_800B00B8[index];
        int *integers = track->integerChannels + frame * track->integerChannelCount;
        float *floats = track->floatChannels + frame * track->floatChannelCount;
        float x;
        float y;
        float z;

        x = track->constantFields & 1 ? track->position[0] : floats[track->channel[0]];
        y = track->constantFields & 2 ? track->position[1] : floats[track->channel[1]];
        z = track->constantFields & 4 ? track->position[2] : floats[track->channel[2]];
        pitch = track->constantFields & 8 ? track->angle[0] : integers[track->channel[3]];
        yaw = track->constantFields & 0x10 ? track->angle[1] : integers[track->channel[4]];
        roll = track->constantFields & 0x20 ? track->angle[2] : integers[track->channel[5]];
        if (D_800AD280 == 8) {
            y = 0.0f;
            pitch = 0;
            D_800B14A8->stringCount = 0;
        }
        func_8003A070(x, y, z);
    }
    func_8003A128(-pitch, yaw + 0x800, roll);
}
