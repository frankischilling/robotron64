# Actor motion recovery

The actor motion pass covers the uncovered functions from `0x80027B9C` through `0x8002818C`. `func_8002818C` is already represented by `src/game/actor_pool_reset.c`, so this pass stops immediately before it.

`func_80027B9C` is complete and byte exact. The function spans `0x80027B9C..0x80027CE4`, 328 bytes. It stores the requested mode in the actor byte at offset `0x20`, transforms the input angle with `0x400 - angle`, selects the corresponding object-mode behavior, updates the object scale/parameter for modes that need it, and returns the requested mode. The matching source is `src/game/actor_motion_mode.c`.

The accepted source SHA-256 is `082171c6aaf34e4eedb7a7f3ba223ad228fb7ea1fd0e9403544875f9ade180ed`. The accepted private header `include/actor_motion_internal.h` has SHA-256 `f929be003acc33cc58849c53824ca4640358f1068af5892e1091a2fbf43d4d72`. The strict verifier reports 328/328 bytes, zero differing words, and no owned-data errors with IDO 5.3 using `-O2 -G 0 -non_shared -mips1 -32`. The compiler archive SHA-256 is `ab5c741561f80913d58c8b074771f23941a3edd312505a8ebed6d1dfeb65e506`, and the compiler executable SHA-256 is `76d796c9591c9f5504949f85b29c32a6039a663791afe2f36f34ca18425b64d0`.

The complete proof, compiled artifacts, disassembly, source snapshot, transitive header snapshots, and input hashes are frozen at `.local/recovery44-actors/frozen/exact-actor_motion_mode-5.3-O2-mips1/`. The exact source and accepted header are also copied to `.local/recovery44-actors/frozen/source/`. `.local/recovery44-actors/frozen-sha256.txt` hashes every file in the frozen handoff.

`func_80027CE4` now matches its complete 168-byte body in
`src/game/actor_motion_facing.c`. Ordering the three existing scalar
declarations reproduces the target frame without adding unused locals.
Its two actor-angle updates and signed remainder behavior are documented in
[Additional runtime recovery](runtime-recovery.md); current canonical proofs
are retained under `.local/recovery67-integration`.

Two neighboring motion functions remain ordinary C candidates:

- `func_80027D8C`, `0x80027D8C..0x80027ED4`, target 328 bytes. The best retained candidate is 328 bytes with 21 differing words. The control flow, filters, early return, linked-list walk, and closest-distance comparison are established. The residual is concentrated in register assignment and the order in which the X/Y deltas are materialized before the two `func_8004CEF0` calls. The retained source snapshot has SHA-256 `7b1213c6e3659fd1b5c028a6e2164575fd9f8e0116375495917e7ed9aa5f1684` and is frozen at `.local/recovery44-actors/frozen/best-actor_motion_find-5.3-O2-mips1/`.
- `func_80027ED4`, `0x80027ED4..0x8002818C`, target 696 bytes. The best retained candidate is 696 bytes with 18 differing words. Its retry loop, random candidate construction, optional axis constraint, actor-spacing rejection, 100-attempt failure path, and final three-word position copy are all represented. The remaining words are register choices and four-byte stack-slot shifts around the candidate position and saved spacing argument; the branch structure and total size already match. The retained source snapshot has SHA-256 `1927da0b86a21a394c6814cdf0601cffa83fe15f0e83ccb12aca9c6113a5672a` and is frozen at `.local/recovery44-actors/frozen/best-actor_motion_position-5.3-O2-mips1/`.

The target accesses in these helpers confirm the actor fields used by the private motion view: object index at `+0x0C`, actor kind at `+0x1C`, animation index at `+0x1F`, mode byte at `+0x20`, resource pointer at `+0x24`, X/Y position words at `+0x60/+0x64`, and linked-list next pointer at `+0x78`. No shared actor header change is required for this handoff.

The larger actor candidates remain outside matching progress:

- `func_80027AB8` in `src/game/actor_animation.c` targets 228 bytes and currently compiles to 224 bytes with 12 differing words. The first 168 target bytes through `0x80027B5F` are reproduced. Every remaining difference begins at the sound-byte tail at `0x80027B60`; the target keeps the sound byte in `v0`, has a different branch/delay-slot schedule, and retains one additional instruction before the common epilogue. Signed/unsigned byte, short, old-style, return-value, and sound-call declaration probes did not justify a shared prototype change. The retained source SHA-256 is `f1d955e31dad7d0f1b08896609e8e1b8da767bdadf66b1f5230b41b40fc11246`; full proof is frozen at `.local/recovery44-actors/frozen/best-actor_animation-5.3-O2-mips1/`.
- `func_8001D3F0` in `src/game/actor_setup_resources.c` targets 2,660 bytes and currently compiles to 2,656 bytes with 428 differing words. The fixed resource loads, special-animation setup, dynamic groups, and scene-arrival processing are represented, but the target still allocates registers and structures several loops differently. Its source-owned 40-byte `.rodata` section also differs from the target, so the switch/jump-table form is not accepted yet. The retained source SHA-256 is `6efa622d2b7c590d3601b5d59ebcf247ebbdbcb45cb971a412c31d9292bb44c9`; full code/data proof is frozen at `.local/recovery44-actors/frozen/best-actor_setup_resources-5.3-O2-mips1/`.
- `func_8001EB2C` in `src/game/actor_setup_text_update.c` is exactly the target size, 1,708 bytes, with 371 differing words. The 20-entry `0x14`-stride runtime records, `0x1C` placement records, elapsed-time positioning, label formatting, two extra labels, transform calls, and timeout cleanup are represented. Reordering the independent formatting streams and the index/Z calculations did not reduce the 371-word residual, which remains broad register/scheduling allocation within the main loop. The retained source SHA-256 is `bc9dcd5f491d12c2169eaeacc518ca052030932a7986c424a2bdf4b1e4b7e3e4`; full proof is frozen at `.local/recovery44-actors/frozen/best-actor_setup_text_update-5.3-O2-mips1/`.

The earlier frozen directories preserve the historical candidates and their
proofs. Current matching status for `func_80027CE4` comes from the complete
canonical comparison above; the other listed candidates remain excluded.
