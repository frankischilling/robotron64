#include "../../include/object_recovery.h"
#include "../../include/debug_output.h"

typedef char DatPointMustBe8Bytes[sizeof(ObjectRecoveryDatPoint) == 8 ? 1 : -1];
typedef char DatRecordMustBe100Bytes[sizeof(ObjectRecoveryDatRecord) == 100 ? 1 : -1];
typedef char DatHeaderMustBe40Bytes[sizeof(ObjectRecoveryDatFile) == 40 ? 1 : -1];

static const unsigned char D_80094C50[] = "Too may points in DAT file %d max=%d\n";

ObjectRecoveryDatFile *func_8003C6B8(ObjectRecoveryDatFile *file)
{
    int index;
    int scale;
    int x;
    int y;
    int z;

    for (index = 0; index < 4; index++) {
        file->sections[index].data = (unsigned char *)file +
                                     (unsigned int)file->sections[index].data;
    }
    file->tailData = (void *)((unsigned int)file->tailData + (unsigned int)file);
    if (file->sections[3].info.scaled.scale <= 0) {
        file->sections[3].info.scaled.scale = 1;
    }
    if (file->sections[0].info.count > 950) {
        func_800496E0((unsigned char *)D_80094C50, file->sections[0].data, 950);
    }
    for (index = 0; index < file->sections[0].info.count; index++) {
        scale = file->sections[3].info.scaled.scale;
        x = ((ObjectRecoveryDatPoint *)file->sections[0].data)[index].x;
        y = ((ObjectRecoveryDatPoint *)file->sections[0].data)[index].y;
        z = ((ObjectRecoveryDatPoint *)file->sections[0].data)[index].z;
        x = scale * x;
        x /= 8;
        y = scale * y;
        y /= 8;
        z = scale * z;
        z /= 8;
        ((ObjectRecoveryDatPoint *)file->sections[0].data)[index].x = x;
        ((ObjectRecoveryDatPoint *)file->sections[0].data)[index].y = y;
        ((ObjectRecoveryDatPoint *)file->sections[0].data)[index].z = z;
    }
    for (index = 0; index < file->sections[3].info.scaled.count; index++) {
        ((ObjectRecoveryDatRecord *)file->sections[3].data)[index].x *= file->sections[3].info.scaled.scale;
        ((ObjectRecoveryDatRecord *)file->sections[3].data)[index].y *= file->sections[3].info.scaled.scale;
        ((ObjectRecoveryDatRecord *)file->sections[3].data)[index].z *= file->sections[3].info.scaled.scale;
        ((ObjectRecoveryDatRecord *)file->sections[3].data)[index].x /= 8;
        ((ObjectRecoveryDatRecord *)file->sections[3].data)[index].y /= 8;
        ((ObjectRecoveryDatRecord *)file->sections[3].data)[index].z /= 8;
    }
    ((ObjectRecoveryDatRecord *)file->sections[3].data)[file->selectedRecord].x = 0;
    ((ObjectRecoveryDatRecord *)file->sections[3].data)[file->selectedRecord].y = 0;
    ((ObjectRecoveryDatRecord *)file->sections[3].data)[file->selectedRecord].z = 0;
    return file;
}
