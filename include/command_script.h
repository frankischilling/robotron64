#ifndef ROBOTRON_COMMAND_SCRIPT_H
#define ROBOTRON_COMMAND_SCRIPT_H

typedef struct CommandScriptEntry {
    void (*handler)(int *command);
    int argumentCount;
} CommandScriptEntry;

typedef char CommandScriptEntryMustBe8Bytes[sizeof(CommandScriptEntry) == 8 ? 1 : -1];

extern int D_8009EFB4;
extern int D_8009EFB8;

void func_80032518(int *command);
void func_80032520(int *command);
void func_80032540(void);
void func_80032550(int value, unsigned char *destination, int base);
int func_8003264C(unsigned char *filename, CommandScriptEntry *commands, int mode);
void func_800327AC(int *command);

#endif
