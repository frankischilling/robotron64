# Bootstrap status

The target is the supplied USA ROM with header revision zero. `config/target.json` records measured hashes of its normalized bytes. Compiler, SDK version, CIC, and complete segment layout remain unknown.

Completed locally:

- Created the public repository and bootstrap branch.
- Installed Git identity and commit-message guards.
- Added byte-order normalization and strict target validation.
- Built a deterministic extraction, assembler, linker, and binary comparison pipeline.
- Matched five functions at `0x80000450..0x800005E0` with IDO 5.3 and MIPS I; documented differences against IDO 7.1 and MIPS II candidates.
- Verified full ROM equality after clean extraction and build.
- Added automated object-byte progress checks and public tooling tests.
- Identified three SDK assembly sequences and two embedded graphics microcode version strings.

Fifty-five C functions contribute 6,576 matched bytes. The source covers text handling, 32 object transform and property helpers, and two startup routines. See [text matching evidence](text.md), [object evidence](object-transforms.md), and [startup evidence](startup.md). Most remaining ROM content uses extracted fallback. Total executable bytes and function count are unknown. Full segment discovery, project-wide compiler identification, SDK version, and subsystem analysis remain open.

The 56-byte boot entry is reconstructed as symbolic assembly, followed by 24 alignment bytes. Its measured assembly bytes are separate from C progress. The initial PI-read loop and thread handoff now reproduce all 304 original bytes from C. A pointer loop with three used scalar locals before its buffer reproduces the observed stack layout.

Public tooling tests check normalization, comparison, padding handling, function metadata, build-input records, and section-address validation without a ROM. The manifest check rejects missing source or evidence files, overlapping ranges, conflicting sources for an object, inconsistent declared placement, and malformed records. Matching progress additionally checks the complete ROM, each linked function, input-object symbols, actual ELF load/runtime addresses, and source/header/object hashes recorded by the build recipes.

See [reference study](reference-study.md) for the inspected source trees, build systems, extraction tools, linker organization, compiler handling, and progress/CI approaches. No implementation code has been copied from them.

[Text record evidence](text-records.md) recovers the 30-record pool and matching allocation/release routines.

[Text option evidence](text-options.md) covers four additional functions and the second compiled switch table.
