# Bootstrap status

The target is the supplied USA ROM with header revision zero. `config/target.json` records measured hashes of its normalized bytes. Compiler, SDK version, CIC, and complete segment layout remain unknown.

Completed locally:

- Created the public repository and bootstrap branch.
- Installed Git identity and commit-message guards.
- Added byte-order normalization and strict target validation.
- Built a deterministic extraction, assembler, linker, and binary comparison pipeline.
- Matched the multiplication function at `0x80000450` using both IDO 5.3 and 7.1.
- Verified full ROM equality after clean extraction and build.
- Added automated object-byte progress checks and public tooling tests.
- Identified three SDK assembly sequences and two embedded graphics microcode version strings.

One C function contributes 16 matched bytes. The rest remains extracted fallback. Total executable bytes and function count are unknown. Public CI configuration is present; its hosted result must be checked after push. Full segment discovery, original compiler identification, SDK version, and subsystem analysis remain open.

See [reference study](reference-study.md) for the inspected source trees, build systems, extraction tools, linker organization, compiler handling, and progress/CI approaches. No implementation code has been copied from them.
