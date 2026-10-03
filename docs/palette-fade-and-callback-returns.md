# Palette fade and effect callback returns

The complete `func_800316AC` replaces 1,148 fallback instruction bytes at
`800316AC..80031B28` (ROM `322AC..32728`). Its source is
`src/game/palette_effects/fade_update.c`. Pinned IDO 5.3 with
`-O2 -G 0 -non_shared -mips1 -32` reproduces all 287 instructions.
The procedure generates no data or BSS and uses the existing palette types.

## Fade behavior

Zero progress returns immediately. Negative progress advances by the step
times the frame delta and clamps crossings to -1. Positive progress retreats
by the same product and clamps negative results to zero. Complementary signed
weights with a limit of 102400 interpolate blue, green, and red for each of
256 colors. Signed division truncates toward zero; the fourth palette byte
is untouched.

The retail procedure computes a local color buffer but never submits it or
copies it elsewhere. The source preserves these stores and the returned fade
progress. Its meaningful local declaration order produces the original
1064-byte frame and buffer at stack offset 36. IDO unrolls the ordinary loop
four colors at a time. The full function symbol is 1,148 bytes; four trailing
zero object-alignment bytes are removed.

The existing caller at `80031658` and retail caller at `80022D24` use the
shared `int func_800316AC(void)` declaration. Signed arithmetic preserves
the pinned compiler's historical overflow behavior and the original clamps.

## Callback result correction

`EarlyGameActorCallback` and all eight associated effect renderer declarations
now return `int`. The boundary spawn declaration agrees with this interface,
and the scene-scale installer uses the shared callback typedef instead of its
separate no-argument void view. These changes recover a result that the object
loop actually consumes; they add no renderer implementation.

The actor allocator passes its actor as the object's draw resource. In the
retail loop at `8003A8B0..8003B254`, the two indirect calls at `8003B0F4`
and `8003B184` pass the resource as the first argument and the object base as
the second. Both store `v0` at stack offset `C4`. After the first call, a
nonzero result causes the loop to add the object's unsigned halfword at
offset `16` to `D_800781F0`. The second stored result is not tested before
the next iteration. Normal epilogues in all eight early callbacks explicitly
return zero; this observation does not establish every unrecovered exit.
Complete bounded listings of `800058F0..80005DEC` and
`800077F4..80007D10` also establish their allocation-failure returns of one.
The listings match retail bytes even where Ghidra's stored function body is
incomplete; the type annotations alone do not establish a full body.

The early declarations retain the one-argument `int(EarlyGameActor *)` view.
The dispatcher uses `int(unsigned int, ObjectRecord *)`. Their argument count
and first-argument type differ, so these are incompatible ISO C function
types. A cast cannot make an incompatible indirect call portable. The current
decompilation retains the historical N64 ABI and partial actor/resource views;
recovering a compatible interface throughout this family remains open.
The later [effect drawing checkpoint](actor-effect-draw.md) recovers all
692 bytes at `80005560..80005814`, including the frame and return sequence.

## Verification and remaining work

All 66 affected accepted units (61 runtime and five data-only) independently
match with the corrected headers. The scene-scale Make rule includes the
complete new transitive header dependencies. Final build-input hashes,
full-ROM comparison, tooling tests, complete independent comparisons, and
live Ghidra evidence are recorded in
`palette-fade-and-callback-returns-provenance.json`.

The clean 8 MiB ROM comparison, all 151 tooling tests, and independent
comparisons of 848 runtime, two startup, eighteen assembly, and 81 data-only
units pass. The checkpoint has 1,365 matching C procedures / 258,812
instruction bytes, 29 assembly procedures / 4,372 bytes, 29,003 initialized
bytes, and 458,883 BSS bytes. The provisional CPU interval retains 191,384
fallback bytes in 219 ranges and 152 unclassified bytes.

Whole-ROM equality still includes extracted fallback ranges. This recovery
does not establish a complete executable or function denominator, and the
game remains partially decompiled. The palette initializer and transition
updater remain private until every instruction matches.

The original retail instructions and live Ghidra program are the behavior
references. Compiler and object-layout practices follow the project's
[documented N64 reference sources](reference-study.md); no reference game code is
copied into this procedure.
