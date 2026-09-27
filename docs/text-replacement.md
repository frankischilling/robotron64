# Text replacement investigation

`func_80000F48`, ROM `0x1B48..0x1DAC`, replaces the contents of an existing 3D text record. The 612-byte original remains in the build as extracted fallback. `src/game/text_replacement.c` is an excluded C candidate, not a matching function.

## Observed behavior

The function computes the replacement length, capped at 60, before checking whether the supplied record index is negative. For inputs shorter than 60 bytes, it calls the length helper twice. With a nonnegative index, it sets packed bit 29 and processes three ranges:

1. Within the overlap between old and new lengths, identical bytes retain their object indices. A changed byte releases its existing object only when that index is nonnegative. It then stores the replacement byte and creates a new object unless the byte is zero or a space; those cases store index -1.
2. For the new suffix of a longer string, it copies bytes and creates objects with the same zero/space rule.
3. For the removed suffix of a shorter string, it calls `func_800392F4` for every stored object index, including negative entries, then sets each entry to -1.

New objects use record scale word `0x70`, mode at `0x08`, and option bit `0x200`. The function updates the stored character count after these loops. It neither copies a new terminator nor clears the removed text bytes. It does not validate the upper bound of the record index or roll back failed object creation.

These findings come from instruction and control-flow inspection. The candidate expresses them, but full source equivalence remains unverified until its generated instructions match.

## Object release return evidence

`func_800392F4` calls `func_8003A3F8` and returns without changing `v0`. The latter returns 1 after marking an allocated object free and decrementing two counters; its rejected-index/already-free path returns zero. The declaration now uses an integer return, although the integrated text callers ignore it and still match byte for byte.

The outer release helper reads `D_800C86C0[object]` before the nested helper's range check. The unconditional calls in the text-truncation path are therefore preserved as observed; the nested check alone does not prove negative arguments are safe.

## Reproduce the comparison

Run in Linux or WSL after preparing the baserom:

```sh
python3 tools/compare_text_replacement.py
```

The tool validates the target, uses the pinned IDO 5.3 toolchain, appends the candidate to the integrated text source for shared recovered types/prototypes, and links at the original addresses. It writes compiler output, linked ELF, extracted text, and `report.json` under `build/text-replacement-comparison/`. Generated files remain outside Git. A nonmatch is reported without failing the research command; this is not a matching acceptance gate.

The current candidate is 608 bytes, compared with 612 target bytes, with 118 differing words after accounting for length. Its 56-byte stack frame and eight saved `s` registers differ from the target's 64-byte frame, which also saves `fp`. Much of the instruction-count and allocation divergence begins around the temporary character value used during replacement. The target keeps that byte in `s1`; the current candidate uses `v0` and emits a different store/branch sequence.

Experiments varied assignment placement, local character types, operand order, pointer-field versus local loads, and declaration order. Isolating the function into its own translation unit did not fix the mismatch. These results do not establish a different compiler: the source expression and live ranges still need investigation. No instruction patching or matching claim has been made.

The production build retains fourteen matching C functions / 2,808 bytes plus 56 assembly bytes. Full ROM verification and the existing tooling tests pass with this candidate excluded.
