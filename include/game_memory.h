#ifndef ROBOTRON_GAME_MEMORY_H
#define ROBOTRON_GAME_MEMORY_H

extern const unsigned char D_8007BB1C[17];

unsigned char *func_8003B4C0(unsigned char *text, unsigned char character);
int func_8003B4FC(unsigned char *text);
void *func_8003B520(void *destination, void *source, int count);
void *func_8003B594(void *destination, void *source, int count);
void *func_8003B694(void *destination, int value, int count);
unsigned char *func_8003B6E4(unsigned char *destination, unsigned char *source);
unsigned char *func_8003B704(unsigned char *destination, unsigned char *source, int limit);
unsigned char *func_8003B734(unsigned char *destination, unsigned char *source);
int func_8003B768(unsigned char *left, unsigned char *right);
int func_8003B7FC(const unsigned char *left, const unsigned char *right);
int func_8003B838(unsigned char *left, unsigned char *right, int count);
int func_8003B8E0(unsigned char *left, unsigned char *right, int count);
void func_8003B928(int value, unsigned char *text, int radix);
void func_8003BA90(float value, unsigned char *text, int radix);
int func_8003BBAC(unsigned char character);
int func_8003BBDC(unsigned char character);
int func_8003BC2C(unsigned char character);
unsigned char func_8003BC5C(unsigned char character);
unsigned char func_8003BC90(unsigned char character);
unsigned char *func_8003BCC4(unsigned char *text);
unsigned char *func_8003BD08(unsigned char *text);
int func_8003BD4C(unsigned char *text);
float func_8003BDE8(unsigned char *text);

#endif
