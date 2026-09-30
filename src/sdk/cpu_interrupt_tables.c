/* Generated from CPU interrupt priority; check tools/generate_interrupt_tables.py. */
const unsigned char D_80095E60[32] = {
    0, 20, 24, 24, 28, 28, 28, 28,
    32, 32, 32, 32, 32, 32, 32, 32,
    0, 4, 8, 8, 12, 12, 12, 12,
    16, 16, 16, 16, 16, 16, 16, 16,
};

extern unsigned char D_80066F18[]; /* redispatch */
extern unsigned char D_80066EE0[]; /* software one */
extern unsigned char D_80066EC0[]; /* software two */
extern unsigned char D_80066D24[]; /* RCP */
extern unsigned char D_80066CD0[]; /* cartridge */
extern unsigned char D_80066E64[]; /* pre-NMI */
extern unsigned char D_80066C98[]; /* CPU interrupt six */
extern unsigned char D_80066CA4[]; /* CPU interrupt seven */
extern unsigned char D_80066CB0[]; /* counter */

unsigned char *const D_80095E80[9] = {
    D_80066F18, D_80066EE0, D_80066EC0,
    D_80066D24, D_80066CD0, D_80066E64,
    D_80066C98, D_80066CA4, D_80066CB0,
};
