#ifndef ROBOTRON_GAME_STDARG_H
#define ROBOTRON_GAME_STDARG_H

/* The game formatters consume integer and pointer arguments from o32 homes. */
typedef unsigned char *va_list;

#define GAME_VA_ALIGNMENT(type) \
    (__builtin_alignof(type) > 4 ? __builtin_alignof(type) : 4)
#define GAME_VA_SIZE(type) ((sizeof(type) + 3) & ~3)

#define va_start(args, last) ((args) = (unsigned char *)&(last) + sizeof(last))
#define va_arg(args, type) \
    ((args) = (unsigned char *)(((unsigned int)(args) + GAME_VA_ALIGNMENT(type) - 1) \
                               & -GAME_VA_ALIGNMENT(type)) + GAME_VA_SIZE(type), \
     *(type *)((args) - GAME_VA_SIZE(type)))
#define va_end(args) ((void)0)

#endif
