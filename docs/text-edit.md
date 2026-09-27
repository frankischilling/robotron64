# Text suffix editing and pool cleanup

Two functions in `src/game/text_edit.c` match all 352 bytes of ROM `0x1E70..0x1FD0` with pinned IDO 5.3 and the project's normal flags.

| Function | ROM range | Bytes | Behavior |
| --- | --- | ---: | --- |
| `func_80001270` | `0x1E70..0x1F60` | 240 | Replace text starting at an offset, using a temporary buffer |
| `func_80001360` | `0x1F60..0x1FD0` | 112 | Release every active record in the 30-entry pool |

## Suffix editing

A negative record index returns zero. Otherwise, the function compares the replacement length plus the requested offset with the stored length. If those differ, or the text comparison helper reports a difference at that offset, it builds a replacement string and returns 1 after calling `func_80000F48`. An unchanged suffix returns zero.

The temporary buffer contains 60 bytes. The function fills it with spaces, copies the existing text without its terminator, then copies the new suffix including its terminator at the requested offset. It passes the resulting buffer to the replacement routine. `func_8003B520` copies a counted sequence of bytes; `func_8003B6E4` copies through the zero byte and returns its destination. These behaviors were checked in the local disassembly.

The original does not check the upper bound of the record index, offset, or temporary-buffer writes. The reconstruction preserves those calls and bounds. A 60-character result would put its terminator past the declared temporary buffer; matching the function does not establish that callers permit that input.

The matching source declares the record pointer before the buffer and uses the length-helper call directly in the condition. Introducing a separate length local changed stack spill offsets; swapping the declaration order changed the buffer offset. The final source matches the target's 104-byte stack frame and every instruction without padding adjustments.

## Pool cleanup

Cleanup walks all 30 records and checks packed bit 31. For each active record, it copies the index into a local and passes that local's address to `func_80000ACC`. This preserves the loop counter when the release helper writes -1 through its argument. Inactive records are skipped.

## Integration and verification

The functions occupy a separate compiled object and linker section. This is build organization, not a claim about original translation-unit boundaries. CPU fallback resumes at ROM `0x1FD0`; the unresolved replacement routine at `0x1B48..0x1DAC` remains fallback.

Linked-byte and input-object-symbol checks confirm both functions' addresses and sizes. The complete 8,388,608-byte ROM matches the target, and all nine tooling tests pass. Matching C progress increases from fifteen functions / 3,004 bytes to seventeen functions / 3,356 bytes. Assembly remains 56 bytes; total code size and whole-game percentage remain unknown.
