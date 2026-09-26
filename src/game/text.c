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

/* Partial layout established by the 88-byte stride and accessed fields. */
typedef struct TextGlyphResource {
    unsigned char unk00;
    unsigned char kind;
    unsigned char unk02[10];
    int scale;
    unsigned char unk10[24];
    short *indices;
    unsigned char unk2C[44];
} TextGlyphResource;

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

/* The fourth argument starts as a flag, then holds the created object index. */
int func_80000750(int character, int scale, int mode, int object)
{
    TextGlyphResource *resource;
    int normalized;

    if (object) {
        object = 1;
    }
    normalized = func_8000060C(character);
    if (normalized == -1) {
        func_8001C0D0(D_8008F620, character);
    } else if (normalized == -2) {
        return -1;
    }
    resource = &D_800B1BE8[normalized];
    object = func_8003921C(resource->kind, 0, object, resource);
    if (object != -1) {
        switch (character) {
        case '&': func_80039E1C(object, 13); break;
        case ';': func_80039E1C(object, 11); break;
        case 149: func_80039E1C(object, 12); break;
        default: func_80039E1C(object, character); break;
        }
        func_8003947C(object, resource->indices[0]);
        func_800399E4(object, (resource->scale * 4 * scale) / 40960.0f);
        func_80039DCC(object, 105);
        if (mode == 11) {
            func_80039E0C(object, mode);
        }
        func_80039E5C(object, 0);
        func_80039E80(object, 24);
    }
    return object;
}
