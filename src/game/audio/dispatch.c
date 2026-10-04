#include "../../../include/audio_engine_tables_internal.h"

extern AudioOperations D_8008D9D0;

/* The engine table shares the driver's first nineteen callback positions. */
AudioOperations *D_8008D800[10] = {
    (AudioOperations *)&D_8008D920,
    &D_8008D9D0,
    (AudioOperations *)&D_8008D920,
    (AudioOperations *)&D_8008D920,
    (AudioOperations *)&D_8008D920,
    (AudioOperations *)&D_8008D920,
    (AudioOperations *)&D_8008D920,
    (AudioOperations *)&D_8008D920,
    (AudioOperations *)&D_8008D920,
    (AudioOperations *)&D_8008D920
};
