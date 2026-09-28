#ifndef ROBOTRON_PAK_FILE_H
#define ROBOTRON_PAK_FILE_H

/* The target callers pass device arguments that this legacy entry ignores. */
int func_8004C378();
int func_8004C3AC(int device, unsigned char *mode);
int func_8004C564(void *destination, int size, int count, int handle);
int func_8004C5DC(void *source, int size, int count, int handle);
int func_8004C648(int handle);
unsigned char *func_8004C65C(unsigned char *name);

extern int D_8008D350;
extern int D_8013DB78;
extern unsigned char D_8013DC10[];
extern unsigned char D_800955F0[];
extern unsigned char D_8009561C[];
extern unsigned char D_80095624[];
extern unsigned char D_80095628[];
extern unsigned char D_80095630[];
extern unsigned char D_80095634[];
extern unsigned char D_8009563C[];

void func_8001C49C(unsigned char *format, ...);

#endif
