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

Ten C functions contribute 1,836 matched bytes; see [text matching evidence](text.md) for character handling, 3D text object creation, and the generated jump table. Most remaining ROM content uses extracted fallback. Total executable bytes and function count are unknown. Public tooling CI passed for the initial pipeline. Full segment discovery, project-wide compiler identification, SDK version, and subsystem analysis remain open.

Follow-up work reconstructs the 56-byte boot entry as symbolic assembly plus 24 alignment bytes. Its measured assembly bytes are separate from C progress. Startup tracing identifies the first two thread handoffs; the excluded C candidate still differs in two local-buffer stack offsets. See [startup evidence](startup.md).

See [reference study](reference-study.md) for the inspected source trees, build systems, extraction tools, linker organization, compiler handling, and progress/CI approaches. No implementation code has been copied from them.

[Text record evidence](text-records.md) recovers the 30-record pool and matching allocation/release routines.
