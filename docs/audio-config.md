# Audio configuration

`src/game/audio_config.c` reconstructs the two configuration routines at `0x80052780..0x800529F8`. Their 632 instruction bytes match IDO 5.3 output with the project's normal flags. The mapped block extends through `0x80052A00` to retain the original eight trailing zero alignment bytes. Its ROM range is `0x53380..0x53600`.

`AudioConfiguration` has a 32-bit flag word followed by fourteen 32-bit values. `func_80052780` applies a value only when its corresponding bit is set. Bits `0x0001` through `0x2000` map in order to the fourteen globals from `D_8008D828` through `D_8008D85C`, at a four-byte stride. Other flag bits have no effect. The routine is 456 bytes.

`func_80052948` clears the caller's flag word and copies all fourteen current values into the record. The routine is 176 bytes. Clearing the flags lets callers choose which returned values to modify and apply; it does not automatically mark the snapshot as a full update.

The game initializer at `0x8005109C` calls the snapshot routine, selects mask `0x115F`, modifies several values, and calls the apply routine. The configuration structure has the observed `0x3C`-byte size. The individual parameters retain numbered fields until their uses establish reliable names.

The C keeps each flag test and store in the original order. In particular, it does not cache the flag word across stores or turn the apply routine into an indexed loop. IDO produces the target's repeated flag loads and delay-slot scheduling from the explicit conditional assignments.

`python3 tools/compare_runtime.py` compares the complete mapped block against the validated local ROM. Function sizes and addresses are also checked through the main manifest and `make progress`; the alignment bytes are verified as part of the ROM but contribute no C-function bytes.
