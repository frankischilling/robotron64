#ifndef ROBOTRON_COMMAND_SCRIPT_H
#define ROBOTRON_COMMAND_SCRIPT_H

typedef struct CommandScriptEntry {
    void (*handler)(int *command);
    int argumentCount;
} CommandScriptEntry;

typedef char CommandScriptEntryMustBe8Bytes[sizeof(CommandScriptEntry) == 8 ? 1 : -1];

int func_8003264C(unsigned char *filename, CommandScriptEntry *commands, int mode);
void func_800327AC(int *command);

#endif
