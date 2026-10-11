# Matching arrival insertion

`func_8001FCE4` owns the complete `8001FCE4..80020134` procedure, or 1,104
instruction bytes. The natural 56-byte frame comes from six consumed locals:
three loop indices, a shared coordinate value, an arrival pointer and state.
Preparing the record pointer before the default-delay decision and ordering
the final trigger, delay and count assignments reproduce retail scheduling.
The shared coordinate value converts each axis with signed division toward
zero while preserving the `-1` sentinel. No initialized or BSS credit is added.

The function retains replacement and insertion ordering, duplicate-state
updates, overlapping copies, random trigger delays, unsigned limits, default
resource delays and the warning after capacity overflow. Replacement at a full
table can copy the last arrival into the three scene words after the array
before warning. Trigger 4 calls the actual random helper even for zero count.

`make audit-scene-arrivals` freshly compares the complete function, six helper
units, scene storage and diagnostics. Its 3,713 paired retail/source fixtures
check the complete scene, random state, copy arguments, resource reads,
coordinate boundaries, argument homes, memory/code guards and saved integer
and floating-point registers. Seven source mutations and two diagnostic-data
mutations must fail after passing baselines. Natural ELF size and absence of
unowned allocated data are checked before acceptance.

Diagnostic output and the fatal renderer use explicit ABI observers that
clobber caller-saved registers. The fatal renderer returns synthetically so
the following stores can be checked. Terminal fatal handling, display hardware,
out-of-range access and unrestricted gameplay remain outside this audit.

Independent Splat and spimdisasm objects reproduce all 1,104 retail bytes.
Fresh matching-workbench, m2c/context, asm-differ, objdiff, pinned IDO and Ghidra
checks support the recovery. The original ROM remains the byte and behavior
reference. Tool and reference credits are in [CREDITS.md](../CREDITS.md).
Full-ROM equality still uses other fallback regions and does not prove full
source completion.
