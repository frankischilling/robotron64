/* Excluded research candidate. Compile with tools/compare_text_replacement.py. */
void func_80000F48(int slot, unsigned char *text)
{
    TextRecord *record;
    int length;
    int index;
    int character;
    int object;
    int space = ' ';

    length = func_8003B4FC(text) < 60 ? func_8003B4FC(text) : 60;
    if (slot >= 0) {
        record = &D_800B6FF8[slot];
        record->unkFlag = 1;
        for (index = 0; index < (length < record->length ? length : record->length); index++) {
            if (record->text[index] != text[index]) {
                object = record->objects[index];
                if (object >= 0) {
                    func_800392F4(object);
                }
                character = record->text[index] = text[index];
                if (character && space != character) {
                    record->objects[index] = func_80000750(character, record->scale[2],
                                                          record->mode, record->options & 0x200);
                } else {
                    record->objects[index] = -1;
                }
            }
        }
        for (; index < length; index++) {
            record->text[index] = text[index];
            character = text[index];
            if (character && space != character) {
                record->objects[index] = func_80000750(character, record->scale[2],
                                                      record->mode, record->options & 0x200);
            } else {
                record->objects[index] = -1;
            }
        }
        for (; index < record->length; index++) {
            func_800392F4(record->objects[index]);
            record->objects[index] = -1;
        }
        record->length = length;
    }
}
