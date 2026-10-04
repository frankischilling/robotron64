#include "../../../include/game_memory.h"
#include "../../../include/error_formatters.h"
#include "../../../include/game_stdarg.h"
#include "../../../include/debug_output.h"
#include "../../../include/error_message_storage_internal.h"

void func_8003CC38(unsigned char *message);


void func_8001C0D0(unsigned char *format, ...)
{
    ErrorMessageStorage storage;
    unsigned char *text;
    int character;
    int marker;
    va_list args;

    text = storage.message;
    character = *format;
    marker = '%';
    va_start(args, format);
    while (character != 0) {
        if (marker == character) {
            format++;
            character = *format;
            switch (character) {
            case 'C':
            case 'c':
                character = (unsigned char)va_arg(args, int);
                *text++ = character;
                break;
            case 's': {
                unsigned char *source;

                source = va_arg(args, unsigned char *);
                func_8003B520(text, source, func_8003B4FC(source) + 1);
                text += func_8003B4FC(text);
                break;
            }
            case 'd':
                func_8003B928(va_arg(args, int), text, 10);
                text += func_8003B4FC(text);
                break;
            case 'x':
                func_8003B928(va_arg(args, int), text, 16);
                text += func_8003B4FC(text);
                break;
            }
            format++;
        } else {
            *text++ = character;
            format++;
        }
        character = *format;
    }
    *text = 0;
    va_end(args);
    func_8003CC38((unsigned char *)D_80090420);
    func_8003CC38(storage.message);
    func_800496E0((unsigned char *)D_80090430, storage.message, D_80090448, 77);
}
