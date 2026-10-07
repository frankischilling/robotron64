# Movie update

`src/game/movie_update.c` replaces the complete 1,816-byte procedure at
`0x80004C3C..0x80005354`, ROM `0x583C..0x5F54`. It adds one matching C
function and no initialized data or BSS. Both retail callers set the
screen-erase argument explicitly: one at `0x800233D0` passes one; the other
at `0x80024420` passes zero.

The procedure selects the movie sound script, handles skip/fade modes,
updates prop animation and primary-frame events, submits camera and string
frames, schedules sound/color events, advances time, and invokes callbacks
whose frame thresholds were crossed. Callback handlers receive zero. The
configuration and track layouts remain those in [movie.h](../include/movie.h).

Animation durations of zero or 100 select the original default of four.
Other signed 16-bit durations are preserved. The source assigns the default
and loaded duration in separate arms, which reproduces the retail copy and
delay slot. A single color-event condition preserves the special five-string
gate, color value and global-state test. Those ordinary source forms resolve
the earlier register differences; no empty condition or padding is inserted.

The saved-session word at offset `0x20` retains the address name `D_800AD158`.
Its linker alias derives from the existing source-owned `D_800AD138`, rather
than creating another storage object. The sound labels remain externally
supplied retail data at `0x8008F914` and `0x8008F920` and add no data credit.

The complete procedure, all 454 instructions, entry, return, 88-byte stack
frame and symbol extent compare independently with pinned IDO 5.3 using
`-O2 -G 0 -non_shared -mips1 -32`. Splat and spimdisasm each reproduce every
retail byte and emit the genuine 1,816-byte procedure size. Fresh and cached
workbench comparisons pass. Asm-differ and objdiff retain their full reference
views; raw symbol/relocation scores are separate from linked-byte acceptance.

The guarded execution audit passes 2,241 retail/C pairs, or 4,482 update
executions. Independent models check complete configurations, all adjacent
guards, ten actor/resource/animation records, the 300-record object pool,
mesh frame counts, saved-session state and fade globals. They also check
every target write and the complete service trace. Execution and read/write
bounds, stack guards, return, and saved O32 registers are enforced.

Cases cover every valid prop/string/indexed/color/callback count, all five
camera-pair slots, null and idle props, both configuration locations, signed
durations and times, mode/skip/fade combinations, repeat termination, callback
thresholds and signed time steps. Every object index from zero through 299
runs under all three guard patterns. The pool's 36,000-byte extent is checked
against its source ownership. Additional controls accept index 299 and reject
indices -1 and 300 on their first out-of-pool byte read in both images. The
earlier 512-record fixture exceeded the retail pool and has been replaced.
Movie status, integer absolute value, object
frame-limit lookup and the retail no-op primary-frame setter execute as real,
freshly compared procedures. Sound, camera/text submission, mesh loading,
palette fading and callback bodies use recorded boundaries that clobber the
caller-saved integer registers and HI/LO.

Movie start sets animation bit `0x20` on every allocated prop. Primary-frame
reads require that setup invariant. Idle-prop fixtures have no primary-frame
events; corrupted setup that reads an uninitialized frame is excluded. The
source preserves the retail calculation instead of inventing an initial frame.

Six isolated source mutations change the default duration, last primary-frame
event, last string, color gate, callback threshold, and time step. All fail
after positive controls pass. Each changed-size image is independently linked
at a separate address so it cannot overwrite the adjacent status procedure.
The unmodified control matches its original bytes there and passes the same
guard before the mutation runs.

Run `make audit-movie-playback PYTHON=python` or
`python tools/check_movie_playback.py --mutations`. The
[proof ledger](movie-playback-provenance.json) records accepted inputs,
complete comparisons, original references and the execution controls.

These finite proofs establish this procedure's matching recovery. Camera/text
rendering, sound hardware, callback bodies, whole movie playback and complete
gameplay remain outside the audit. The ROM build still uses extracted fallback
code and assets, and full source recovery remains incomplete.

The recovery uses the original Robotron 64 ROM, Ghidra, pinned IDO, splat,
spimdisasm, m2c, asm-differ, objdiff and Unicorn. See [credits](../CREDITS.md).
