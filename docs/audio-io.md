# Audio transfer and conversion helpers

Seven functions from `0x80051854` through `0x80051A0C` reproduce 436 instruction bytes with IDO 5.3 and the project's normal flags. The ROM mapping is `0x52454..0x5260C`. The build uses separate objects at `0x80051854` and `0x800518E0`, preserving four original alignment bytes between the groups.

| Function | Bytes | Observed behavior |
| --- | ---: | --- |
| `func_80051854` | 52 | Multiply the argument by twelve, narrow to one byte, and call `func_800549DC`. |
| `func_80051888` | 52 | Apply the same conversion before calling `func_80054790`. |
| `func_800518BC` | 32 | Call `func_80053C50` with argument seven. |
| `func_800518E0` | 16 | Return the low 32 bits of the unsigned argument squared. |
| `func_800518F0` | 52 | Fill the requested number of bytes with the supplied byte value. |
| `func_80051924` | 156 | Prepare and submit a device read, wait for its completion, and return the requested count. |
| `func_800519C0` | 76 | Convert a duration using the supplied frequency and round the resulting integer down to an eight-unit boundary. |

## Transfer request

`func_80051924` returns zero without touching memory when audio state `D_8008D7A4` is zero or the requested byte count is zero. Otherwise it calls `func_80065790` on the destination, submits a request through `func_80065840`, and waits on `D_80190228` with receive flag one. The original ignores the submit and receive return values; the C retains that behavior.

The local `AudioTransferRequest` has the observed 24-byte layout. The called routine writes a halfword type at `0x00`, byte priority at `0x02`, completion-queue pointer at `0x04`, destination at `0x08`, device address at `0x0C`, byte count at `0x10`, and zero at `0x14`. The request lives at stack offset `0x30`, the returned message at `0x2C`, and the complete stack frame is 72 bytes. Explicit fields reproduce that layout without artificial padding locals.

## Numeric behavior

The sample-count helper evaluates `value * (frequency / 1000.0f)` in single precision, converts that result to a signed integer, and clears its low three bits. IDO emits the target's floating-point control-register save, truncation mode, conversion, and restore sequence. The source does not replace that sequence with a different rounding rule or move the division after the multiplication.

Both byte-fill helpers retain the target's decrementing unsigned count and increasing destination pointer. A zero count stores nothing. The two multiply-by-twelve wrappers retain the target's one-byte conversion; their callees consume that byte from the argument's stack home when assembling commands.

The adjacent scheduler wrapper `func_80050FB0` forwards its incoming argument to `func_80053C50`. Reading the latter's call to `func_80055760` established that its first argument is live. The shared declaration in `include/audio_game.h` therefore retains that argument across both callers.

## Verification

`python3 tools/compare_runtime.py` compiles and compares both complete mapped blocks. `make progress` checks each function's source and header hashes, input-object symbol size, linked address, section placement, and final bytes. Alignment bytes are checked by the full ROM comparison and excluded from the C-byte total.
