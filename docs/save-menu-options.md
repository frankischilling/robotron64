# Menu option construction

The complete option initializer at `800263E0..800265B8` contains 472 bytes
and 118 instructions. The pinned IDO 5.3 game profile reproduces its full
instruction range from `src/game/save_menus/define_options.c`.

The initializer limits positive counts to sixteen and reports excessive
counts through the existing diagnostic. It writes one 40-byte record per
option, followed by a cancel record, then opens the 48-byte page through
`80026178`. Counts below zero skip record construction; zero creates only
the cancel record. The original code still opens the page in both cases.
The sixth argument is unused.

The record before the cancel entry receives spacing 30; other records,
including the cancel entry, receive 20. Each record points to the page's
selection word. Normal entries retain the supplied label twice and store
the selection callback. The cancel entry uses `80093820`, flags `28900`,
and the cancellation callback. A callback union preserves the two supplied
function types without invoking either callback in this routine.

The initializer computes the maximum label length without using the result.
It calls the real length routine a second time whenever a new maximum is
found. Those calls and their order are retained. The final page receives the
supplied title, width, mode and first value, alongside the original fixed
defaults. Fields whose wider meaning remains unknown retain offset names.

The seventeen option records own `800AEF00..800AF1A8`, 680 bytes of BSS;
the page owns `800AF1A8..800AF1D8`, another 48 bytes. These definitions claim
runtime storage and no ROM data. The existing label updater retains its
40-byte stride. Navigation still uses its older partial page and option
views; this change does not establish a complete shared menu representation.
The diagnostic and cancel-label storage remain fallback.

The execution checker passes 1,024 cases: 896 direct calls and 128 calls through
the two existing menu callers. It executes the real matching string-length
routine and, in 512 cases, the matching label updater. Independent byte oracles
check all 728 bytes of storage, surrounding guards, untouched fields, labels,
strings and call order. Every invocation must return and restore saved registers
and the stack. Diagnostic output, page activation, input reset and the second
caller's continuation use ABI stubs that clobber caller-saved integer registers.
Callback invocation and full-game behavior are outside this proof.

Run the optional checker with Unicorn installed:

```sh
python3 tools/check_menu_options.py
```

The integrated ROM matches all 8,388,608 target bytes. Independent comparisons
pass for 855 runtime units, two startup units, eighteen assembly units and
94 data-only units; all 152 tooling tests pass.
[The provenance ledger](save-menu-options-provenance.json) records current
inputs, compiler identity, ELF ownership, execution results and Ghidra layouts.
The larger 616-byte page-activation routine at `80026178` remains excluded.
The compiler and comparison workflow follow the local SM64 and IDO
references listed in [reference study](reference-study.md); no reference
game implementation was copied.
