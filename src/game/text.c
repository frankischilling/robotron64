#include "../../include/text.h"

/* Names remain address-based until callers establish the public interface. */

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

void func_800005E0(void)
{
    func_8003B694(D_800B6FF8, 0, sizeof(D_800B6FF8));
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
    object = func_8003921C(resource->kind, 0, (ObjectDrawResource *)object,
                            (ObjectModel *)resource);
    if (object != -1) {
        switch (character) {
        case '&': func_80039E1C(object, 13); break;
        case ';': func_80039E1C(object, 11); break;
        case 149: func_80039E1C(object, 12); break;
        default: func_80039E1C(object, character); break;
        }
        func_8003947C(object, resource->animation.indices[0]);
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

int func_80000918(unsigned char *text, int scale, int mode, int options)
{
    TextRecord *record;
    int slot;
    int index;
    int character;
    int space = ' ';

    for (slot = 0; slot < 30; slot++) {
        if (!D_800B6FF8[slot].active) {
            record = &D_800B6FF8[slot];
            record->options = options;
            record->mode = mode;
            record->active = 1;
            record->flag30 = 1;
            record->property64 = 24;
            record->length = func_8003B4FC(text) < 60 ? func_8003B4FC(text) : 60;
            record->scale[0] = record->scale[1] = record->scale[2] = scale;
            record->sentinel[0] = record->sentinel[1] = record->sentinel[2] = 0xDEADBEEF;
            func_8003B704(record->text, text, 60);
            for (index = 0; index < record->length; index++) {
                character = record->text[index];
                if (character && space != character) {
                    record->objects[index] = func_80000750(character, scale, mode,
                                                          record->options & 0x200);
                } else {
                    record->objects[index] = -1;
                }
            }
            return slot;
        }
    }
    func_8001C0D0(D_8008F64C);
    return -1;
}

void func_80000ACC(int *slot)
{
    TextRecord *record;
    int index;
    int object;

    if (*slot >= 0) {
        record = &D_800B6FF8[*slot];
        record->active = 0;
        for (index = 0; index < record->length; index++) {
            object = record->objects[index];
            if (object >= 0) {
                func_800392F4(object);
            }
        }
        *slot = -1;
    }
}

void func_80000B7C(int slot, int set, int clear)
{
    TextRecord *record;
    int index;
    int bit;
    int object;
    int selectedOption = 0x10000;

    if (slot >= 0) {
        record = &D_800B6FF8[slot];
        record->options |= set & 0x3FFFF;
        record->options &= ~clear;
        for (index = 0; index < 18; index++) {
            bit = 1 << index;
            if (bit & set) {
                switch (bit) {
                case 0x10000:
                    object = record->objects[record->objectIndex20];
                    if (object >= 0) {
                        func_80039E80(object, 88);
                    }
                    break;
                case 0x200:
                    record->value1C = D_8009EFA4;
                    break;
                case 0x2000:
                    record->unk04 = set >> 18;
                    record->scale[0] = record->scale[1] * 2;
                    record->value0C = D_8009EFA4;
                    break;
                case 4:
                    record->value0C = D_8009EFA4;
                    record->scale[2] = 2 * record->scale[1];
                    break;
                case 0x1000:
                    record->unk04 = set >> 18;
                    record->value0C = D_8009EFA4;
                    record->scale[0] = record->scale[1];
                    break;
                case 1: case 2:
                    record->value0C = D_8009EFA4;
                    record->scale[2] = record->scale[1];
                    break;
                case 0x400:
                    record->unk04 = set >> 18;
                    break;
                case 0x20:
                    record->value10 = D_8009EFA4;
                    break;
                case 0x10:
                    record->value14 = D_8009EFA4;
                    break;
                case 0x80: case 0x100:
                    record->value18 = D_8009EFA4;
                    break;
                case 0x8000:
                    record->objectIndex20 = set >> 18;
                    break;
                case 8: case 0x800: case 0x4000: case 0x20000:
                    break;
                }
            }
        }
        for (index = 0; index < 18; index++) {
            bit = 1 << index;
            if (bit & clear) {
                if (selectedOption == bit) {
                    object = record->objects[record->objectIndex20];
                    if (object >= 0) {
                        func_80039E80(object, (unsigned char)record->property64);
                    }
                }
            }
        }
    }
}

int func_80000E74(int slot)
{
    if (slot >= 0) {
        return D_800B6FF8[slot].options;
    }
    return -1;
}

void func_80000EB4(int slot, TextValue3 *value)
{
    if (slot >= 0) {
        *value = D_800B6FF8[slot].valueF4;
    }
}

int func_80000F08(int slot)
{
    if (slot >= 0) {
        return D_8009EFA4 - D_800B6FF8[slot].value0C;
    }
    return 0;
}
