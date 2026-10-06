#include "../../../include/palette_effects.h"
#include "../../../include/game_memory.h"

void func_80031ECC(void)
{
    PaletteTransition *transition;
    int i;
    int count;
    int j;
    unsigned char index;
    int position;
    int inverse;
    int mode;
    unsigned int updatedPosition;
    PaletteColor colors[256];
    int changed[256];
    func_8003B694(changed, 0, sizeof(changed));
    for (i = 0; i < 100; i++)
    {
        transition = &D_8009D120[i];
        if (D_8009D120[i].active != 0)
        {
            index = D_8009D120[i].paletteIndex;
            changed[index] = 1;
            switch (D_8009D120[i].mode)
            {
                case 32:
                    inverse = ((transition->position / 32) + transition->phase) % transition->second;
                    mode = transition->first + inverse;
                    D_8009CD18[index].red = D_800BB230[mode].red;
                    D_8009CD18[index].green = D_800BB230[mode].green;
                    D_8009CD18[index].blue = D_800BB230[mode].blue;
                    break;

                case 16:
                    position = transition->first + ((transition->position / 32) % transition->second);
                    D_8009CD18[index].red = D_800BB230[position].red;
                    D_8009CD18[index].green = D_800BB230[position].green;
                    D_8009CD18[index].blue = D_800BB230[position].blue;
                    break;

                case 8:
                    inverse = ((D_8009D120[i].position / 32) + D_8009D120[i].first) % D_8009D120[i].second;
                    mode = D_80077C20[inverse];
                    D_8009CD18[index].red = D_800BB230[mode].red;
                    D_8009CD18[index].green = D_800BB230[mode].green;
                    D_8009CD18[index].blue = D_800BB230[mode].blue;
                    break;

                default:
                    position = transition->position;
                    inverse = 65536 - position;
                    D_8009CD18[index].blue = ((transition->endBlue * position) + (transition->startBlue * inverse)) / 65536;
                    D_8009CD18[index].green = ((transition->endGreen * position) + (transition->startGreen * inverse)) / 65536;
                    D_8009CD18[index].red = ((transition->endRed * position) + (transition->startRed * inverse)) / 65536;
                    break;

            }

            colors[index] = D_8009CD18[index];
            func_8003C0DC(&colors[index], index);
            transition = &D_8009D120[i];
            /* Preserve the pinned IDO evaluation order. The index assignment and
             * color argument reads are unsequenced in ISO C; see palette-transitions.md. */
            func_80046EA8(index = D_8009D120[i].paletteIndex,
                         colors[index].red, colors[index].green, colors[index].blue);
            updatedPosition = (transition->position += (D_8009D120[i].step * 32) / 32);
            inverse = D_8009D120[i].position;
            if ((int)updatedPosition < 0)
            {
                j = D_8009D120[i].mode;
                if ((j & 4) != 0)
                {
                    D_8009D120[i].active = 0;
                    continue;
                }
                if ((j & 2) != 0)
                {
                    position = -inverse;
                    transition->position = position & 0xFFFF;
                    inverse = D_8009D120[i].position;
                }
                else
                {
                    transition->position = inverse & 0xFFFF;
                    inverse = D_8009D120[i].position;
                }
            }
            if (inverse > 65535)
            {
                if ((D_8009D120[i].mode & 2) != 0)
                {
                    D_8009D120[i].position = (131072 - inverse) & 0xFFFF;
                }
                else
                {
                    D_8009D120[i].position = inverse & 0xFFFF;
                }
            }
        }
    }

    for (i = 0; i < 256; i++)
    {
        count = 1;
        j = i + 1;
        if (changed[i] != 0)
        {
            while ((j < 256) && (changed[j] != 0))
            {
                count++;
                j++;
            }

            func_8003C020(&colors[i], i, count);
        }
    }

}
