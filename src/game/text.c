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
