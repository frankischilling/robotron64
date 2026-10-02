#include "../../../include/game_memory.h"
#include "../../../include/game_stdarg.h"

void func_80048DC0();
void func_8004C6E0(void);
extern unsigned char D_8009542C[];

/* Nonmatching candidate; see docs/renderer-diagnostics-and-text.md. */
void func_800496E0(unsigned char *format, ...)
{
    unsigned char message[256];
    unsigned char *text;
    int character;
    int marker;
    va_list args;

    text = message;
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
                character = va_arg(args, unsigned char);
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
            default:
                va_arg(args, int);
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
    func_80048DC0(D_8009542C, message);
    func_8004C6E0();
    while (1) {}
}
