# Movie recovery and remaining candidates

The camera, actor and main movie updates now match as complete C procedures.
`src/game/movie_camera.c` reproduces all 460 bytes of `func_80003ECC`, and
`src/game/movie_actor.c` reproduces all 436 bytes of `func_80004258`.
Their channel selection, special actor-kind adjustments, movie-mode override,
and camera/object calls are documented in
[Additional runtime recovery](runtime-recovery.md).

The camera source limits position-sampling locals to their use before the
final orientation call. The actor source caches the actor kind for its
height-adjustment test. Both reproduce the original stack slots using
ordinary, initialized source. Complete canonical source/header snapshots,
byte comparisons, and procedure-boundary proofs are under
`.local/recovery67-integration` with IDO 5.3 and
`-O2 -G 0 -non_shared -mips1 -32`.

The generic script loader also matches as a complete C procedure. The
earlier residuals below record compiler evidence from its excluded candidate;
the accepted source and proof are in
[Actor effects and command scripts](actor-effects-and-command-scripts.md).

## Movie update

`src/game/movie_update.c` now reproduces all 1,816 bytes of `func_80004C3C`.
Explicit default duration selection and the original combined color-event
condition resolve the earlier register differences. Both independent assembly
references, fresh and cached workbench comparisons, 1,341 guarded execution
pairs and six isolated mutations pass. See [movie update](movie-playback.md).

The earlier decomp-permuter run under `.local/recovery17-movie-update/perm_func_80004C3C/output-0-1` has a score of zero, but its source inserts an empty condition that reads `wholeFrame` before assignment. That source is deliberately rejected: the emitted bytes are useful compiler evidence, but the condition has no program meaning and cannot be used as recovered C.

The target has two direct callers, at `800233D0` with `a0 = 1` and `80024420` with `a0 = 0`, confirming the screen-erase parameter and the complete `1816`-byte range.

## Generic command script loader

The earlier candidate for `func_8003264C` had four residual words at `800326F4`, `800326F8`, `80032708`, and `8003270C`. The target compares the loaded opcode as `bne v0, s3`, masks it into `t6`, shifts the masked value into `v1`, and adds that byte offset to the command table. That candidate used the same values and control flow with the temporary registers interchanged.

Signed and unsigned command pointers, constant-first comparisons, pointer-index spelling, inline byte-offset expressions, block-scoped opcode/offset locals, and `register` qualifiers were checked. Reusing the raw opcode for the masked index subsequently recovered its original temporary lifetimes. The accepted `src/game/command_scripts/execute.c` reproduces all 352 bytes and is rechecked by the current independent runtime comparison.

Target callers occur at `800044E0`, `8001CB98`, `8001CBD0`, `8001CCE0`, and `8001CD48`. They consistently pass the filename in `a0`, a command table in `a1`, and the mode in `a2`, confirming the public signature and the `352`-byte range.

No shared layout change was needed to resolve these differences. The established `MovieTrackState` size and offsets, `GameActor` layout, and command entry size remain required by the complete matches.
