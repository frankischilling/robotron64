/* Names remain address-based until callers establish the public interface. */
extern int D_80072B40[];
extern int D_80072BA8[];

unsigned int func_80000450(unsigned int value)
{
    return value * value;
}

int func_80000460(int enabled, unsigned char character)
{
    int width = 5;

    if (enabled) {
        if (character >= 'a' && character <= 'z') {
            width = D_80072B40[character - 'a'];
        } else if (character >= 170 && character <= 179) {
            width = D_80072BA8[character - 170];
        } else if (character >= '0' && character <= '9') {
            width = D_80072BA8[character - '0'];
        } else if (character == ' ') {
            width = 2;
        } else if (character == '-') {
            width = 4;
        }
    }
    return width + 1;
}

unsigned char *func_80000518(unsigned char *text)
{
    unsigned char *start = text;

    if (text == 0) {
        return 0;
    }
    while (*text) {
        if (*text >= '0' && *text <= '9') {
            *text += 122;
        }
        text++;
    }
    return start;
}

unsigned char *func_80000568(unsigned char *text)
{
    unsigned char *start = text;

    while (*text) {
        if (*text >= 170 && *text <= 179) {
            *text -= 122;
        }
        text++;
    }
    return start;
}

void func_800005A4(unsigned char *text)
{
    while (*text) {
        if (*text >= 'a' && *text <= 'z') {
            *text -= 32;
        }
        text++;
    }
}

extern unsigned char D_800B6FF8[];
extern void *func_8003B694(void *destination, int value, int count);

void func_800005E0(void)
{
    func_8003B694(D_800B6FF8, 0, 0x1F68);
}

int func_8000060C(int character)
{
    if (character >= 'A' && character <= 'Z') {
        return (character & 31) + 96;
    }
    if (!((character >= 'a' && character <= 'z') ||
        (character >= '0' && character <= '9') ||
        (character >= 170 && character <= 179))) {
        switch (character) {
        case '/': character = ':'; break;
        case '=': character = '['; break;
        case '%': character = ']'; break;
        case '-': character = 220; break;
        case '?': character = '_'; break;
        case '!': character = '\\'; break;
        case '.': character = '^'; break;
        case ',': character = 'Z'; break;
        case '*': character = '`'; break;
        case '"': case '#': case '\'': case '+': case ':': case '@':
            character = ':'; break;
        case ' ': case '\\': return -2;
        case 23: case '&': case ';': case '[': case '^': case '_': case 149:
            break;
        default: return -1;
        }
    }
    return character;
}
