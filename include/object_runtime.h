#ifndef ROBOTRON_OBJECT_RUNTIME_H
#define ROBOTRON_OBJECT_RUNTIME_H

extern unsigned char D_80078274[];

void func_8003A8B0(void);
int func_8003B254(void);
void func_8003B2B0(int index, int frame);
void func_8003B428(int *indices);

/* These callees home an unused incoming word; legacy callers set no argument. */
void func_800428C0();
void func_80042E2C();

#endif
