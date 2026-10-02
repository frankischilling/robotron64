#include "../../../include/destination_format.h"
#include "../../../include/game_memory.h"
#include "../../../include/game_stdarg.h"

#define DESTINATION_VA_BYTE(args) ((args) = (unsigned char *)(((unsigned int)(args) + 3) & ~3) + 4, *((args) - 1))

unsigned char *func_800363D0(unsigned char *destination, unsigned char *format, ...)
{
    unsigned char *text;
    int character;
    int width;
    va_list args;

    text = destination;
    character = *format;
    va_start(args, format);
    while (character != 0) {
        if (character == '%') {
            format++;
            character = *format;
            switch (character) {
            case 'C':
            case 'c':
                character = DESTINATION_VA_BYTE(args);
                *text++ = character;
                break;
            case 's': {
                unsigned char *source;

                source = va_arg(args, unsigned char *);
                func_8003B520(text, source, func_8003B4FC(source) + 1);
                text += func_8003B4FC(text);
                break;
            }
            case '2':
                width = 2;
                format++;
                goto decimal;
            case '3':
                width = 3;
                format++;
                goto decimal;
            case '4':
                width = 4;
                format++;
                goto decimal;
            case '5':
                width = 5;
                format++;
                goto decimal;
            case 'd':
                width = 0;
            decimal:
                func_8003B928(va_arg(args, int), text, 10);
                {
                    int length;
                    int padding;
                    length = func_8003B4FC(text);
                    padding = width;
                    while (length <= padding) {
                        func_8003B594(text + 1, text, func_8003B4FC(text) + 1);
                        *text = ' ';
                        length = func_8003B4FC(text);
                    }
                }
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
    return destination;
}
