#ifndef ROBOTRON_COMPRESSION_INTERNAL_H
#define ROBOTRON_COMPRESSION_INTERNAL_H

#include "audio_io.h"

typedef struct InflateCode {
    unsigned char operation;
    unsigned char bits;
    union {
        unsigned short value;
        struct InflateCode *table;
    } data;
} InflateCode;

typedef char InflateCodeMustBe8Bytes[sizeof(InflateCode) == 8 ? 1 : -1];

extern InflateCode *D_8008DA40;
extern InflateCode *D_8008DA44;
extern unsigned short D_8008DA94[];
extern unsigned short D_8008DAD4[];
extern unsigned short D_8008DB14[];
extern unsigned short D_8008DB50[];
extern unsigned short D_8008DB8C[];
extern unsigned char *D_80192BD0;
extern unsigned char *D_80192BD4;
extern unsigned int D_80192BD8;
extern unsigned char *D_80192BDC;
extern int D_80192BE0;
extern int D_80192BE4;
extern int D_80192BE8;
extern unsigned int D_80192BEC;
extern unsigned char *D_80192BF0;
extern unsigned int D_80192BF4;
extern unsigned char *D_80192BF8;
extern unsigned char *D_80192BFC;
extern unsigned int D_80192C00;
extern unsigned int D_80192C04;
extern unsigned int D_80192C08;
extern unsigned int D_80192C0C;

int func_8005DA20(unsigned int *lengths, unsigned int count, unsigned int simpleCount,
                  unsigned short *bases, unsigned short *extraBits,
                  InflateCode **result, unsigned int *lookupBits);
void func_8005E1E4(InflateCode *table);
int func_8005E1EC(InflateCode *literalTable, InflateCode *distanceTable,
                  unsigned int literalBits, unsigned int distanceBits);
int func_8005E9D0(void);
int func_8005ECA8(void);
void func_8005EE98(void);
int func_8005EEE0(void);
int func_8005F71C(void *scratch, unsigned int size, int memoryInput);
void *func_8005F7E0(unsigned int size);
unsigned char func_8005F804(void);
int func_8005F878(void *destination, void *scratch, unsigned int size);
int func_8005FAB0(unsigned char *source, void *destination, void *scratch, unsigned int size);
int func_8005FB08(unsigned int source, void *destination, void *scratch, unsigned int size);
int func_8005FB58(unsigned int source, void *destination, unsigned int outputLimit,
                  void *scratch, unsigned int size);

#define INFLATE_READ_BYTE() \
    ((D_80192BE4 || D_80192BE0-- > 0) ? *D_80192BD0++ : func_8005F804())

#define INFLATE_NEED_BITS(count) \
    do { \
        while (bitCount < (count)) { \
            bitBuffer |= (unsigned int)INFLATE_READ_BYTE() << bitCount; \
            bitCount += 8; \
        } \
    } while (0)

#define INFLATE_DROP_BITS(count) \
    do { \
        bitBuffer >>= (count); \
        bitCount -= (count); \
    } while (0)

#define INFLATE_ADVANCE_WINDOW(count) \
    do { D_80192BF0 += (count); (count) = 0; } while (0)

#endif
