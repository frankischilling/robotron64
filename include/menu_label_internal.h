#ifndef ROBOTRON_MENU_LABEL_INTERNAL_H
#define ROBOTRON_MENU_LABEL_INTERNAL_H

#include "save_game.h"

#define MENU_OPTION_LIMIT 16
#define MENU_OPTION_RECORD_COUNT (MENU_OPTION_LIMIT + 1)

/* Preserve the two callback argument types supplied by the existing callers. */
typedef union MenuLabelCallback {
    /* C89 initializers store either callback without changing its prototype. */
    void (*entry)();
    void (*select)(int *);
    void (*cancel)(int);
} MenuLabelCallback;

typedef struct MenuLabelRecord {
    unsigned int flags00;
    MenuLabelCallback callback04;
    unsigned char *label08;
    unsigned char *label0C;
    int textSlot10;
    int *selection14;
    struct MenuLabelRecord *next18;
    int spacing1C;
    int value20;
    int sound24;
} MenuLabelRecord;

/* Scalar callback arguments share the verified 40-byte label layout. */
typedef struct MenuScalarLabelRecord {
    unsigned int flags00;
    MenuLabelCallback callback04;
    unsigned char *label08;
    unsigned char *label0C;
    int textSlot10;
    int argument14;
    struct MenuScalarLabelRecord *next18;
    int spacing1C;
    int value20;
    int sound24;
} MenuScalarLabelRecord;
typedef char MenuScalarLabelRecordMustBe40Bytes[sizeof(MenuScalarLabelRecord)==40?1:-1];

typedef struct MenuOptionsPage {
    unsigned char *title00;
    int textSlot04;
    int value08;
    int width0C;
    int value10;
    int selection14;
    int value18;
    int value1C;
    MenuLabelRecord *child20;
    int sound24;
    int mode28;
    int preview2C;
} MenuOptionsPage;

typedef char MenuLabelCallbackMustBe4Bytes[
    sizeof(MenuLabelCallback) == 4 ? 1 : -1];
typedef char MenuLabelRecordMustBe40Bytes[
    sizeof(MenuLabelRecord) == 0x28 ? 1 : -1];
typedef char MenuOptionsPageMustBe48Bytes[
    sizeof(MenuOptionsPage) == 0x30 ? 1 : -1];

extern MenuLabelRecord D_800AEF00[MENU_OPTION_RECORD_COUNT];
extern MenuOptionsPage D_800AF1A8;

void func_800263E0(unsigned char *title, unsigned char **labels, int count,
                   int mode, int first, int second,
                   void (*select)(int *), void (*cancel)(int), int width);

#endif
