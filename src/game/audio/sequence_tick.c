#include "../../../include/audio_host_internal.h"
#include "../../../include/audio_engine_tables_internal.h"
/* Keep the decoder visible to IDO's call-effect analysis. Its own object owns
 * the body at 0x80059580; the build retains only this complete tick function. */
#include "../audio_stream_variable_read.c"

extern unsigned char D_8008D9B4;
extern AudioVoice *D_8008D9B8;
extern AudioContext *D_8008D9C0;

void func_8005A9AC(void)
{
    static AudioVoice *D_80192800;
    static unsigned char D_80192804;
    static unsigned int D_80192808;
    static int D_8019280C;

    D_80192804 = D_8008D9C0->activeVoiceCount;
    if (D_80192804) {
        D_80192808 = D_8008D9B4;
        D_80192800 = D_8008D9B8;
        while (D_80192808--) {
            if (D_80192800->flag80) {
                if (!D_80192800->paused) {
                    D_80192800->unknown20 += D_80192800->property1C;
                    D_80192800->position28 += (unsigned int)D_80192800->unknown20 >> 16;
                    D_80192800->unknown24 += (unsigned int)D_80192800->unknown20 >> 16;
                    D_80192800->unknown20 &= 0xFFFF;
                    if (D_80192800->flag08 &&
                        (unsigned int)D_80192800->position2C <= D_80192800->position28) {
                        D_8008D800[D_80192800->backend]->stopVoice(D_80192800);
                    } else {
                        while (D_80192800->delay <= (unsigned int)D_80192800->unknown24 &&
                               D_80192800->flag80 && !D_80192800->paused) {
                            D_80192800->unknown24 -= D_80192800->delay;
                            D_8019280C = *D_80192800->command;
                            if (D_8019280C >= 7 && D_8019280C < 19) {
                                D_8008D800[D_80192800->backend]->commands[D_8019280C - 7](D_80192800);
                                D_80192800->command += D_8008D8D0[D_8019280C];
                                D_80192800->command = func_80059580(D_80192800->command, &D_80192800->delay);
                            } else if (D_8019280C >= 19 && D_8019280C < 36) {
                                D_8008D96C[D_8019280C - 19](D_80192800);
                                if (D_80192800->flag80 && !D_80192800->commandRedirect) {
                                    D_80192800->command += D_8008D8D0[D_8019280C];
                                    D_80192800->command = func_80059580(D_80192800->command, &D_80192800->delay);
                                } else {
                                    D_80192800->commandRedirect = 0;
                                }
                            } else {
                                D_8008D96C[10](D_80192800);
                            }
                        }
                    }
                }
                if (!--D_80192804) break;
            }
            D_80192800++;
        }
    }
    D_8008D800[D_8008D9B8->backend]->frameUpdate(D_8008D9B8);
}
