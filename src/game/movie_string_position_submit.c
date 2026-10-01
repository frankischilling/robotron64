#include "../../include/movie.h"

typedef struct MovieStringPosition {
    float x;
    float y;
    float z;
} MovieStringPosition;

typedef char MovieStringPositionMustBe12Bytes[
    sizeof(MovieStringPosition) == 12 ? 1 : -1];

extern int D_800B6FEC;

void func_8000177C(int slot, int x, int z, int y, int pitch, int yaw,
                   int roll, int scale, int first, int second, int third,
                   int enabled, int state, int limit, int value);

void func_80002D70(int slot, int index, int frame, int scale, int unused0,
                   int unused1, int unused2, int value)
{
    int x;
    int y;
    int z;
    int pitch;
    int yaw;
    int roll;
    MovieStringPosition position;

    func_80004098(frame, index, (float *)&position, &pitch, &yaw, &roll);
    x = (int)(position.x * 60000.0f / 1400.0f);
    z = (int)(position.z * 60000.0f / 1400.0f);
    y = -(int)(position.y * 60000.0f / 1400.0f);
    func_8000177C(slot, x, z, y,
                   pitch + 2048, yaw, roll, (int)(scale * 0.7),
                   0, 0, 0, 1, D_800B6FEC, 32767, value);
}
