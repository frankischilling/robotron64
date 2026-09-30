#ifndef ROBOTRON_RENDERER_TEXTURE_INDEX_H
#define ROBOTRON_RENDERER_TEXTURE_INDEX_H

typedef struct TextureIndexRecord {
    unsigned char *data;
    int unknown04;
} TextureIndexRecord;

typedef char TextureIndexRecordMustBe8Bytes[
    sizeof(TextureIndexRecord) == 8 ? 1 : -1];

extern TextureIndexRecord D_8007BAC4[];

void func_8004AD64(unsigned char *data, int value);
int func_80005814(int table, int texture, int value);

#endif
