#include "../../include/command_script.h"
#include "../../include/platform_services.h"
#include "../../include/game_memory.h"
#include "../../include/text.h"

extern unsigned char D_80094110[];
extern char D_80094118[];

int func_8003264C(unsigned char *filename, CommandScriptEntry *commands, int mode)
{
    int *cursor;
    /* The retail loop increments this signed halfword without reading it. */
    short count;
    int *data;
    CommandScriptEntry *entry;
    int size;

    D_8009EFB8 = 1;
    func_8003B6E4(func_8003B4C0(filename, '.'), D_80094110);
    data = func_8003C64C(filename, &size);
    cursor = data;
    if (data == 0) {
        func_8001C0D0(D_80094118);
        return 0;
    }
    count = 0;
    while (D_8009EFB4 == 0) {
        if (*cursor == -1) {
            D_8009EFB4 = 1;
        } else {
            entry = &commands[*cursor & 0x7fff];
            if (entry->handler != 0 && (D_8009EFB8 != 0 || (*cursor & 0x7fff) == 0)) {
                entry->handler(cursor);
            }
            cursor += entry->argumentCount + 1;
        }
        count++;
    }
    func_8003C698(data);
    D_8009EFB4 = 0;
    return 1;
}
