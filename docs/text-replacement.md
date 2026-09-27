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

The tool validates the target, compiles the candidate independently using the recovered layouts and prototypes in `include/text.h`, and links at the original address. It writes compiler output, linked ELF, extracted text, and `report.json` under `build/text-replacement-comparison/`. The report records source and header hashes. Generated files remain outside Git. A nonmatch is reported without failing the research command; this is not a matching acceptance gate.

The current candidate is 612 bytes, equal to the target size, with 38 differing words. Its 64-byte frame and saved registers now agree with the target. Reusing the existing object local to hold the incoming byte before the byte store accounts for this improvement: the compiler now keeps the converted character in `s1`. Remaining differences include register allocation for the loop index, record-byte pointer, incoming byte, and old object, plus the release call's delay slot.

The compiler matrix for this candidate is:

| IDO | Optimization | ISA | Bytes | Differing words |
| --- | --- | --- | ---: | ---: |
| 5.3 | O1 | MIPS I | 928 | 230 |
| 5.3 | O1 | MIPS II | 832 | 206 |
| 5.3 | O2 | MIPS I | 612 | 38 |
| 5.3 | O2 | MIPS II | 584 | 133 |
| 7.1 | O1 | MIPS I | 904 | 225 |
| 7.1 | O1 | MIPS II | 808 | 200 |
| 7.1 | O2 | MIPS I | 612 | 49 |
| 7.1 | O2 | MIPS II | 584 | 133 |

Select a configuration with `--compiler 7.1 --optimization O2 --isa 1`. Use `--source path/to/candidate.c` to compare an alternative without changing the maintained candidate. The default remains IDO 5.3, O2, MIPS I. These results favor further source investigation with the existing settings; they do not prove the original compiler version.

All 720 permutations of the six local declarations retained at least 38 differing words. Additional temporary reuse and operand-order experiments did not improve the linked comparison.

Experiments varied assignment placement, local character types, operand order, pointer-field versus local loads, declaration order, and statement line placement. A local [decomp-permuter](https://github.com/simonlindholm/decomp-permuter) search at revision `059609d4aec73eb0650726772954e1ad575825f8` suggested the adopted byte temporary. Search scores were checked against linked bytes. Variants with altered function return types, uninitialized reads, or artificial empty conditions were rejected. No instruction patching or matching claim has been made.

The production build retains fifty-five matching C functions / 6,576 bytes plus 56 assembly bytes, including the separately matched wrapper. Full ROM verification and the tooling tests cover the build with this candidate excluded.
