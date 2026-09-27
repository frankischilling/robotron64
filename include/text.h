#ifndef ROBOTRON_TEXT_H
#define ROBOTRON_TEXT_H

/* Recovered layouts; offset-based fields remain under investigation. */
typedef struct TextValue3 {
    unsigned int words[3];
} TextValue3;

typedef struct TextRecord {
    unsigned int active : 1;
    unsigned int flag30 : 1;
    unsigned int unkFlag : 1;
    signed int options : 18;
    unsigned int unkBits : 11;
    int unk04;
    int mode;
    int value0C;
    int value10;
    int value14;
    int value18;
    int value1C;
    int objectIndex20;
    unsigned char text[64];
    int property64;
    int scale[3];
    int length;
    short objects[60];
    int unkF0;
    TextValue3 valueF4;
    unsigned int sentinel[3];
} TextRecord;

typedef struct TextGlyphResource {
    unsigned char unk00;
    unsigned char kind;
    unsigned char unk02[10];
    int scale;
    unsigned char unk10[24];
    short *indices;
    unsigned char unk2C[44];
} TextGlyphResource;

extern int D_80072B40[];
extern int D_80072BA8[];
extern TextRecord D_800B6FF8[30];
extern void *func_8003B694(void *destination, int value, int count);
extern TextGlyphResource D_800B1BE8[];
extern char D_8008F620[];
extern void func_8001C0D0(char *format, ...);
extern int func_8003921C(int kind, int value, int enabled, TextGlyphResource *resource);
extern int func_80039E1C(int object, int value);
extern int func_8003947C(int object, int index);
extern void func_800399E4(int object, float scale);
extern void func_80039DCC(int object, int value);
extern int func_80039E0C(int object, int mode);
extern void func_80039E5C(int object, int value);
extern void func_80039E80(int object, int value);
extern int func_8003B4FC(unsigned char *text);
extern unsigned char *func_8003B704(unsigned char *destination, unsigned char *source, int limit);
extern char D_8008F64C[];
extern int func_800392F4(int object);
extern int D_8009EFA4;

unsigned int func_80000450(unsigned int value);
int func_80000460(int enabled, unsigned char character);
unsigned char *func_80000518(unsigned char *text);
unsigned char *func_80000568(unsigned char *text);
void func_800005A4(unsigned char *text);
void func_800005E0(void);
int func_8000060C(int character);
int func_80000750(int character, int scale, int mode, int object);
int func_80000918(unsigned char *text, int scale, int mode, int options);
void func_80000ACC(int *slot);
void func_80000B7C(int slot, int set, int clear);
int func_80000E74(int slot);
void func_80000EB4(int slot, TextValue3 *value);
int func_80000F08(int slot);

extern int func_8003B7FC(unsigned char *left, unsigned char *right);
void func_80000F48(int slot, unsigned char *text);
int func_800011AC(int *slot, unsigned char *text, int scale, int mode, int replace, int options);

extern void *func_8003B520(void *destination, void *source, int count);
extern unsigned char *func_8003B6E4(unsigned char *destination, unsigned char *source);
int func_80001270(int slot, int offset, unsigned char *text);
void func_80001360(void);

#endif
