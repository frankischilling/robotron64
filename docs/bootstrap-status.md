# Bootstrap status

The target is the supplied USA ROM with header revision zero. `config/target.json` records measured hashes of its normalized bytes. Compiler, SDK version, CIC, and complete segment layout remain unknown.

Completed locally:

- Created the public repository and bootstrap branch.
- Installed Git identity and commit-message guards.
- Added byte-order normalization and strict target validation.
- Disassembled startup and identified a small multiplication function.

The build, extraction layout, compiler comparison, matching C, automated progress, and CI are still pending. No function has been claimed matching. Total executable bytes and function count are unknown.

Reference study started with the current repository pages for [SM64](https://github.com/n64decomp/sm64), [Ocarina of Time](https://github.com/zeldaret/oot), [Majora's Mask](https://github.com/zeldaret/mm), and [Perfect Dark](https://github.com/n64decomp/perfect_dark). Detailed source and build-system inspection is still pending. No code has been copied from them.
