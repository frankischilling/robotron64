#ifndef ROBOTRON_ERROR_FORMATTERS_H
#define ROBOTRON_ERROR_FORMATTERS_H

extern const char D_80090420[16];
extern const char D_80090430[24];
extern const char D_80090448[12];
extern const char D_80090454[12];

/* These two procedures remain outside the matching function manifest. */
void func_8001C0D0(unsigned char *format, ...);
void func_8001C2C4(unsigned char *format, ...);

#endif
