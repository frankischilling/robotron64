# Movie storage

The movie track pool and configuration are defined in C and linked as two
complete `NOLOAD` sections. They add 6,936 source-owned BSS bytes and no
instructions or initialized ROM data.

| Source | Global | Runtime range | Bytes |
| --- | --- | --- | ---: |
| `src/game/movie_storage/tracks.c` | `D_800B00B8` | `0x800B00B8..0x800B14A4` | 5,100 |
| `src/game/movie_storage/configuration.c` | `D_800B14B0` | `0x800B14B0..0x800B1BDC` | 1,836 |

The retail reset at `0x80002EE0..0x80002F28` clears exactly `0x13EC` bytes
from the track base and `0x72C` bytes from the configuration base. The track
loader scans 25 entries with a 204-byte stride, copies a complete 204-byte
file header, and then updates the selected entry's ownership fields. These
instructions establish the storage boundaries independently of distances
between symbols. The 12 bytes between the pool and configuration remain
outside these declarations.

The existing [`movie.h`](../include/movie.h) describes both types. Track
channels occupy the first 13 words; the identifier is at `0x34`, active flag
at `0x74`, channel counts at `0x84` and `0x88`, and channel pointers at
`0xC4` and `0xC8`. The configuration contains the original fixed prop,
color, string and callback arrays. Fields whose meaning remains uncertain
retain their offset names. See [movie commands](movie-commands.md) for the
consumer instruction ranges and field evidence.

The storage audit compiles the definitions and complete consumer units with
the pinned IDO profile. It checks the two section sizes, alignment, symbol
positions, absence of executable or initialized content, and guarded retail
execution of reset, track lookup/loading/release and callback registration.
The real matching byte-copy, clear and string routines execute inside the
harness. Resource loading, release and diagnostic services use recorded
boundaries that clobber caller-saved integer registers.

All 687 paired cases pass: three complete resets, 75 existing-track lookups,
300 loads, 300 releases and nine callback registrations. The cases cover
every valid track slot, all four integer/float channel-presence combinations
and every valid callback slot. Complete objects, adjacent gaps and guards,
service arguments/order, returns and saved O32 registers are checked. Reset
must write each of the 6,936 buffer bytes exactly once and clear the separate
active flag. Five isolated source mutations fail after their controls pass.

Pinned IDO and Ghidra agree on 164 size, alignment and ordinary-field checks
across nine types and 73 fields. The existing `MovieProp` bit-field semantics
are not newly credited. Ghidra's two storage globals and four consumer
prototypes are typed and saved. The three original instruction ranges total
992 bytes and retain four genuine procedure extents. Both splat and
spimdisasm reassemble every byte; the complete three source units also pass
fresh and cached workbench comparisons. Asm-differ and objdiff retain their
reference views and raw symbol/relocation scores separately from acceptance.

The fresh checkpoint passes 905 runtime, two startup, 18 assembly and 169
data-only comparisons. Linux passes all 163 tooling tests; Windows passes
159 with four Linux-only skips. A build from an empty `build/us` reproduces
all 8,388,608 retail ROM bytes. The SHA-256 is
`91d85baeca4b9517e93b3637b52909cee942b09e2fe44a37df9ded17687faddd`.
The [current ledger](movie-storage-provenance.json) records the accepted
sources, headers, toolchain, layouts, comparisons and execution controls.

Run `make audit-movie-storage PYTHON=python` for the storage audit, or
`python tools/check_movie_storage.py --mutations` to include isolated controls.

Storage ownership does not establish full movie playback, frame interpolation,
rendering or gameplay parity. The ROM build still includes extracted fallback
code and assets. The remaining report declares 141,912 fallback CPU bytes in
187 spans and 164 unclassified bytes; complete function boundaries and the
executable-byte denominator remain unresolved.

The recovery uses the original Robotron 64 ROM, Ghidra, pinned IDO, splat,
spimdisasm, m2c, asm-differ, objdiff and Unicorn. See [credits](../CREDITS.md).
