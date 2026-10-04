#ifndef ROBOTRON_ERROR_MESSAGE_STORAGE_INTERNAL_H
#define ROBOTRON_ERROR_MESSAGE_STORAGE_INTERNAL_H

/* Reconstructed stack storage, not an identified original declaration.
 * The unreferenced region's purpose is unknown. See docs/error-formatter-frames.md.
 */
typedef struct ErrorMessageStorage {
    unsigned char unreferenced[504];
    unsigned char message[500];
} ErrorMessageStorage;

typedef char ErrorMessageStorageMustBe1004Bytes[
    sizeof(ErrorMessageStorage) == 1004 ? 1 : -1];

#endif
