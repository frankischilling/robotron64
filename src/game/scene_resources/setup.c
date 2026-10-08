/* Complete scene setup research; code and generated table remain nonmatching. */
#include "../../../include/actor_setup_internal.h"
#include "../../../include/actor_lifecycle_internal.h"
#include "../../../include/game_memory.h"
void func_8001C0D0(char *format, ...);
extern unsigned char D_800A4578[];
/* The loader views the first 88 bytes of each 104-byte resource record. */
#define RESOURCE68(i) ((TextGlyphResource *)&D_800AF1F0[(i)])

void func_8001D3F0(int mode)
{
    TextGlyphResource *resource;
    ActorResource5CInternal *record;
    ActorAnimation *animation;
    ActorSetupChainEntryInternal *chain;
    int group;
    int item;
    int arrival;
    int index;

    D_800B8F78.word00.fields.flags00 &= ~0x80;
    D_800B8F78.value04 = 0;
    D_800B8F78.word00.fields.flags00 &= ~0x40;
    D_800B8F78.word00.fields.flags00 &= ~0x20;
    D_800B8F78.word00.fields.flags00 &= ~0x10;
    D_800B8F78.word00.fields.value02 = D_800B8F78.value04;
    if (mode != 3) {
        resource = D_800B5658;
        do {
            func_8001CF68(resource, 0);
            resource++;
        } while (resource < D_800B59C8);
        resource = D_800B3D40;
        do {
            func_8001CF68(resource, 0);
            resource++;
        } while (resource != D_800B4630);
        func_8001CF68(&D_800B28F8, 0);
        func_8001CF68(&D_800B4F20, 0);
        func_8001CF68(&D_800B3030, 0);
        func_8001CF68(&D_800B3AD8, 0);
        func_8001CF68(&D_800B3B30, 0);
        func_8001CF68(&D_800B3B88, 0);
        func_8001CF68(&D_800B3BE0, 0);
        func_8001CF68(&D_800B6788, 0);
        func_8001CF68(&D_800B3C38, 0);
        func_8001CF68(&D_800B3C90, 0);
        func_8001CF68(&D_800B3CE8, 0);
        func_8001CF68(&D_800B2FD8, 0);
    }
    if (mode == 1) {
        func_8001CF68(&D_800B4F20, 1);
        func_8001CF68(&D_800B4F78, 1);
    }
    if (mode == 2) {
        if (func_8001CF68(&D_8009B138, 1) == 1) {
            if (D_80074A20++ == 0) {
                func_8003B520(D_8009AFC0,
                    &D_8009B138.animation.tracks[8]->field08, 8);
                func_8003B520(D_8009AFC8,
                    &D_8009B138.animation.tracks[1]->field08, 8);
            }
            animation = D_800A4538;
            do {
                func_8001CE70(&D_8009B138, animation,
                    D_8009B138.animation.tracks[8]->loopIndex);
                animation++;
            } while (animation < D_800A4538 + 2);
            animation = D_800A4558;
            do {
                func_8001CE70(&D_8009B138, animation,
                    D_8009B138.animation.tracks[1]->loopIndex);
                animation++;
            } while (animation != (ActorAnimation *)&D_800A4578);
        }
        func_8001CF68(D_8009AFD8, 1);
        func_8001CF68(&D_8009B030, 1);
        func_8001CF68(&D_8009B088, 1);
        func_8001CF68(&D_8009B0E0, 1);
        record = D_800AC998;
        do {
            func_8001CF68((TextGlyphResource *)record, 1);
            record++;
        } while (record < (ActorResource5CInternal *)D_800ACD8C);
        record = D_8009AA00;
        do {
            func_8001CF68((TextGlyphResource *)record, 0);
            record++;
        } while (record < D_8009AA00 + 16);
        resource = D_800B1F58;
        do {
            func_8001CF68(resource, 1);
            resource++;
        } while (resource < D_800B2110);
        func_8001CF68(&D_800B2270, 1);
        func_8001CF68(&D_800B23D0, 1);
        func_8001CF68(&D_800B2428, 1);
        func_8001CF68(&D_800B2480, 1);
        func_8001CF68(&D_800B26E8, 1);
        func_8001CF68(&D_800B2740, 1);
        func_8001CF68(&D_800B4D10, 1);
        func_80036670();
        if (D_800B9A78.resourceC44 != -1) {
            func_8001CF68(&D_8009F9D8, 1);
            func_8001CF68(&D_8009F8D0, 1);
        }
        if (D_800B9A78.resourceCD4 != -1) {
            for (group = 0; group < D_800AE4F4->groupCount; group++) {
                for (item = 0; item < D_800AE4F4->firstGroups[group].count; item++) {
                    func_8001CF68(RESOURCE68(
                        D_800AE4F4->firstGroups[group].entries[item].resourceIndex), 1);
                }
            }
        }
        for (arrival = 0; arrival < D_800B9A78.arrivalCount; arrival++) {
            switch (D_800B9A78.arrivals[arrival].category) {
            case 1:
                D_800B8F78.word00.fields.flags00 |= 0x20;
                D_800B8F78.word00.fields.value02 += D_800B9A78.arrivals[arrival].count;
                func_8001CF68(&D_8009F560[D_800B9A78.arrivals[arrival].resourceIndex], 1);
                break;
            case 7:
                index = D_800B9A78.arrivals[arrival].resourceIndex;
                if (index == 3 || index == 4)
                    D_800B8F78.word00.fields.flags00 |= 0x10;
                break;
            case 9:
                func_8001CF68(&D_800B1BE8[D_800B9A78.arrivals[arrival].resourceIndex], 1);
                break;
            case 0:
                func_8001CF68(RESOURCE68(
                    D_800B9A78.arrivals[arrival].resourceIndex), 1);
                index = D_800B9A78.arrivals[arrival].resourceIndex;
                if (index >= 25 && index < 29)
                    D_800B8F78.word00.fields.flags00 |= 0x80;
                if (index == 28) {
                    func_8001CF68(&D_800B27F0, 1);
                    index = D_800B9A78.arrivals[arrival].resourceIndex;
                }
                if (index == 24 || index == 20) {
                    func_8001CF68((TextGlyphResource *)&D_800AFF58, 1);
                    func_8001CF68((TextGlyphResource *)&D_800AFFC0, 1);
                    index = D_800B9A78.arrivals[arrival].resourceIndex;
                }
                if (index == 14) {
                    func_8001CF68(&D_8009F928, 1);
                    index = D_800B9A78.arrivals[arrival].resourceIndex;
                }
                if (index == 4) {
                    func_8001CF68(&D_8009F878, 1);
                    index = D_800B9A78.arrivals[arrival].resourceIndex;
                }
                if (index >= 9 && index < 13) {
                    func_8001CF68(RESOURCE68(index + 4), 1);
                    index = D_800B9A78.arrivals[arrival].resourceIndex;
                    if (index == 10) {
                        func_8001CF68(&D_8009F928, 1);
                        index = D_800B9A78.arrivals[arrival].resourceIndex;
                    }
                }
                if (index >= 17 && index < 21)
                    func_8001CF68(RESOURCE68(index + 4), 1);
                break;
            case 8:
                D_800B8F78.word00.fields.flags00 |= 0x40;
                for (item = 0;
                     item < D_8009EA18[D_800B9A78.arrivals[arrival].resourceIndex].count; item++) {
                    func_8001CF68(&D_8009EA18[
                        D_800B9A78.arrivals[arrival].resourceIndex].resources[item].resource, 1);
                }
                for (chain = D_80073590; chain->actorResourceIndex > 0; chain++) {
                    func_8001CF68(&D_800B1BE8[chain->actorResourceIndex], 1);
                    if (chain->extraResourceIndex != -1)
                        func_8001CF68(RESOURCE68(chain->extraResourceIndex), 1);
                }
                func_8001CF68((TextGlyphResource *)&D_800AFF58, 1);
                for (chain = D_80073590; chain->actorResourceIndex != -1; chain++)
                    func_8001CF68(&D_800B1BE8[chain->actorResourceIndex], 1);
                break;
            case 3:
                func_8001CF68(&D_800ACE58[D_800B9A78.arrivals[arrival].resourceIndex], 1);
                if ((D_800B8F78.word00.value & 0x90000000) != 0)
                    func_8001CF68(&D_800ACE58[D_800B9A78.arrivals[arrival].resourceIndex + 4], 1);
                D_800B8F7C += D_800B9A78.arrivals[arrival].count;
                break;
            default:
                func_8001C0D0((char *)D_800907A8, D_800B9A78.arrivals[arrival].category);
                break;
            }
        }
    }
}
