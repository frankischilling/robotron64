# Three-component conversion helper

`func_800016D8` at ROM `0x22D8..0x237C` matches all 164 bytes generated from `src/game/text_conversion.c`. It reads three signed integers, converts all three to single-precision values, then converts them back to integers and stores them in place. The second argument is saved to its incoming argument slot but otherwise unused; its source type is not established beyond that word-sized slot.

This is not an identity operation for every signed integer: single precision cannot represent every large integer exactly. The source retains three float temporaries and the original load-before-store order. The compiled integer conversions preserve the target's floating-point control-register save, rounding-mode change, and restore sequences. The matching result does not establish how callers use this helper, or define portable C behavior when the rounded float cannot fit a signed integer.

The function is compiled separately and placed at RAM `0x800016D8`. Twelve trailing zero alignment bytes are removed after checking symbols and relocations; no instruction bytes are patched. The linked-byte and input-object-symbol checks pass, and the complete 8,388,608-byte ROM matches. All nine tooling tests pass. Matching C increases to twenty-one functions / 4,296 bytes, plus 56 assembly bytes.

## Next routine: initial inventory

`func_8000177C` spans ROM `0x237C..0x3970` (5,620 bytes) and allocates a 320-byte stack frame. It remains extracted fallback. Initial disassembly inspection identifies a negative-index exit and repeated accesses to the selected `TextRecord`; a complete control-flow reconstruction remains outstanding.

Direct call sites include the character mapper `func_80000460`, the option setter `func_80000B7C`, object helpers from `func_80039514` through `func_80039E80`, and unresolved helpers `func_8003CC58`, `func_8003CC88`, `func_8003D20C`, and `func_8004CEF0`. It also contains one call to the diagnostic formatter `func_8001C0D0`. These are static call sites, not runtime call counts.

Observed record writes include the packed flags at offset zero, the property at `0x64`, scale words at `0x68` and `0x70`, the three-word value at `0xF4..0xFC`, and state words at `0x100..0x108`. This inventory identifies dependencies for the next reconstruction without assigning unverified meanings to the remaining fields.
