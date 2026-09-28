#ifndef ROBOTRON_SDK_IO_H
#define ROBOTRON_SDK_IO_H

unsigned int func_800606A0(void *address);
unsigned int func_80068190(void *address);
void func_8006AFF0(unsigned int status);
unsigned int func_8006B000(void);
int func_8006B320(unsigned int pc);
int func_8006B360(int direction, unsigned int deviceAddress, void *dramAddress,
                  unsigned int size);
int func_8006B3F0(void);
int func_8006B5B0(void);

#endif
