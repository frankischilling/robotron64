# Text record create-or-replace wrapper

`func_800011AC` occupies ROM `0x1DAC..0x1E70` and RAM `0x800011AC..0x80001270`. All 196 bytes generated from `src/game/text_wrapper.c` match the validated target with pinned IDO 5.3 and the normal project flags.

The wrapper receives a pointer to a record index, text, scale, mode, a replacement flag, and options. If the stored index equals -1, it calls the text allocator and stores its result through the pointer. With nonzero options, it then calls the option setter with those bits and a zero clear mask. This path returns 1 even if allocation returned -1; the result identifies the creation path, not successful allocation.

For any other stored index, a nonzero replacement flag enables a call to `func_8003B7FC` with the supplied text and the record's stored text. Only a nonzero comparison result triggers `func_80000F48`. The existing-record path returns zero whether it replaces the text or leaves it alone. The wrapper does not independently validate the index or pointer.

The function is compiled in a separate object because the intervening replacement routine is still nonmatching. This organization does not assert an original translation-unit boundary. The linker retains exactly 612 fallback bytes for that routine, places the compiled wrapper at its original address, and resumes CPU fallback at ROM `0x1E70`. The padding tool removes 12 zero bytes after the wrapper's 196-byte symbol; it does not modify instructions.

Verification checks the linked function bytes, source-object symbol address and size, and the entire rebuilt ROM. Progress increases to fifteen C functions / 3,004 bytes, plus 56 assembly bytes. The replacement candidate remains excluded, and full code/function totals remain unknown.
