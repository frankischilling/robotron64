#include "../../include/movie.h"
#include "../../include/actor.h"
#include "../../include/frame.h"
#include "../../include/object_helpers.h"
#include "../../include/scene_audio.h"

extern int D_800AE560;
extern int D_800B6FCC;

void func_80039EA0(int value, int mode);
void func_8002836C(void);
void func_80031564(void);

void func_8000544C(void)
{
    int index;

    func_80039EA0(D_800AE560, 1);
    func_8003A1E4(2400.0f);
    for (index = 0; index < D_800B14A8->stringCount; index++) {
        func_80000ACC(&D_800B14A8->strings[index].field04);
    }
    for (index = 0; index < D_800B14A8->propCount; index++) {
        if (D_800B14A8->props[index].actor != 0) {
            D_800B14A8->props[index].actor->state = 2;
        }
    }
    func_8002836C();
    D_800B6FCC = 0;
    func_8001F8E8(0, 0, 10, 0, 0);
    func_80031564();
}
