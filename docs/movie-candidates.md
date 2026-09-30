# Movie recovery and remaining candidates

The camera and actor movie updates now match as complete C procedures.
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

The two routines below remain excluded. Their retained comparison records
describe the unresolved instruction differences; neither contributes C
progress until its complete procedure matches.

| Function | Target range | Bytes | Retained ordinary-source residual |
| --- | --- | ---: | ---: |
| `func_80004C3C` | `80004C3C..80005354` | 1,816 | 13 words |
| `func_8003264C` | `8003264C..800327AC` | 352 | 4 words |

## Movie update

The current `func_80004C3C` candidate is exact outside `80005000..8000509C`. Its 13 residual words describe one register-allocation difference in the frame-time calculation: the target keeps `field28` in `a1`, while the candidate starts it in `a0` and then uses `a1` for the divided whole-frame value. The arithmetic, signed divide corrections, branches, and all surrounding code are otherwise identical.

Two ordinary experiments reduce this to eight words by reusing either the incoming `eraseScreen` parameter or the earlier `triggerIndex` variable for `field28`. They are preserved as `.local/recovery34-movies/best/movie_update-8word-eraseScreen.c` and `.local/recovery34-movies/best/movie_update-8word-triggerIndex.c`. Neither form has enough source evidence to replace the clearer current candidate.

The earlier decomp-permuter run under `.local/recovery17-movie-update/perm_func_80004C3C/output-0-1` has a score of zero, but its source inserts an empty condition that reads `wholeFrame` before assignment. That source is deliberately rejected: the emitted bytes are useful compiler evidence, but the condition has no program meaning and cannot be used as recovered C.

The target has two direct callers, at `800233D0` with `a0 = 1` and `80024420` with `a0 = 0`, confirming the screen-erase parameter and the complete `1816`-byte range.

## Generic command script loader

`func_8003264C` has four residual words at `800326F4`, `800326F8`, `80032708`, and `8003270C`. The target compares the loaded opcode as `bne v0, s3`, masks it into `t6`, shifts the masked value into `v1`, and adds that byte offset to the command table. The candidate uses the same values and control flow with the temporary registers interchanged.

Signed and unsigned command pointers, constant-first comparisons, pointer-index spelling, inline byte-offset expressions, block-scoped opcode/offset locals, and `register` qualifiers were all checked. The simplest table-index source remains the four-word result and is retained.

Target callers occur at `800044E0`, `8001CB98`, `8001CBD0`, `8001CCE0`, and `8001CD48`. They consistently pass the filename in `a0`, a command table in `a1`, and the mode in `a2`, confirming the public signature and the `352`-byte range.

No shared `movie.h`, `actor.h`, or `command_script.h` change is supported by these residuals. The established `MovieTrackState` size and offsets, `GameActor` layout, and command entry size are all required by byte-identical instructions outside the listed words.
