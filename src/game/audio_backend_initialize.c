#include "../../include/audio_bank_layout_internal.h"

void func_8005B3A8(AudioContext *context)
{
    static int D_80192ABC;

    D_80192810 = context;
    D_80192828 = (unsigned int *)D_80192810->unknown00;
    D_80192814 = D_80192810->instances;
    D_80192818 = D_80192810->voices;
    D_8019281C = D_80192810->statusRecords;
    D_80192824 = (AudioPatchBank *)D_80192810->unknown14;
    D_80192820 = D_8008D83C;
    D_8019282C = (AudioPatchRecord *)D_80192824->data;
    D_80192830 = (AudioPatchRegion *)(D_8019282C + D_80192824->patchCount);
    D_80192830 = AUDIO_BANK_ALIGN(D_80192830);
    D_80192834 = (AudioWaveRecord *)(D_80192830 + D_80192824->regionCount);
    D_80192834 = AUDIO_BANK_ALIGN(D_80192834);
    D_80192838 = (unsigned int *)(D_80192834 + D_80192824->waveCount);
    D_80192838 = AUDIO_BANK_ALIGN(D_80192838);
    D_8019283C = (AudioLoopGroup *)(D_80192838 + D_80192824->drumCount);
    D_8019283C = AUDIO_BANK_ALIGN(D_8019283C);
    D_80192840 = (unsigned char *)(D_8019283C + 1);
    D_80192844 = D_80192840 + D_8019283C->rawCount * AUDIO_BANK_STRIDE(AudioRawLoop);
    D_80192848 = (AudioAdpcmBook *)(D_80192844 + D_8019283C->adpcmCount * AUDIO_BANK_STRIDE(AudioAdpcmLoop));
    for (D_80192ABC = 0; D_80192ABC < D_80192824->waveCount; D_80192ABC++) {
        D_80192834[D_80192ABC].data += D_80192A98;
        D_80192834[D_80192ABC].flags = 1;
        D_80192834[D_80192ABC].tuning = (int)D_80192834[D_80192ABC].loop;
        if (D_80192834[D_80192ABC].type == 1) {
            if ((int)D_80192834[D_80192ABC].book != -1) {
                D_80192834[D_80192ABC].loop = D_80192840 +
                    (int)D_80192834[D_80192ABC].book * AUDIO_BANK_STRIDE(AudioRawLoop);
            } else {
                D_80192834[D_80192ABC].loop = &D_80192850;
            }
        } else {
            if ((int)D_80192834[D_80192ABC].book != -1) {
                D_80192834[D_80192ABC].loop = D_80192844 +
                    (int)D_80192834[D_80192ABC].book * AUDIO_BANK_STRIDE(AudioAdpcmLoop);
            } else {
                D_80192834[D_80192ABC].loop = &D_80192860;
            }
            D_80192834[D_80192ABC].book = &D_80192848[D_80192ABC];
        }
    }
}
