# Movie track files

`src/game/movie_files.c` recovers both complete functions at
`0x80003A7C..0x80003D74`. IDO 5.3 with
`-O2 -G 0 -non_shared -mips1 -32` produces all 760 target bytes exactly.
The loader occupies 636 bytes; the release routine occupies 124 bytes.
Neither function defines initialized data or BSS.

The loader searches the twenty-five `MovieTrackState` records for an active
entry with the requested identifier. An existing entry returns its pool index.
Otherwise it constructs a track path, finds the first inactive entry, and
selects it through `D_800972A0`. The header file supplies the complete
`0xCC`-byte track record. After copying that record, the loader frees the
temporary header allocation and loads the integer and floating-point channel
files when their respective channel counts are nonzero. It then sets the
active flag and identifier and returns the selected index.

The source preserves the target's 256-byte path and 64-byte filename buffers,
the extension replacement calls, and the order of the metadata and channel
loads. Exhausting the pool invokes the original diagnostic. The following
code is retained as emitted by the target, including its behavior if that
diagnostic returns. The recovery adds no new file-size or allocation guards.

The release routine clears the selected entry's active flag before freeing
its channel buffers. Each free is controlled by the corresponding channel
count; the pointer fields and counts are left as the target leaves them.
Direct indexed access to the shared pool gives the target's pointer lifetime
across the free calls. A cached local track pointer generates two different
stack-slot operands and is excluded from the accepted source.

The independently compiled proof, complete linked bytes, compiler identity,
and transitive source/header hashes are recorded in
`build/sdk-options/movie_files-5.3-O2-mips1/report.json`. Earlier source and
header versions are retained in `.local/recovery27-movies/original`; failed
source-level hypotheses remain in that directory's private probe records.

Camera application, actor sampling, the movie update loop, and the generic
script interpreter remain separate candidates. Their matching status is
determined by their own complete comparisons, not by the track loader's result.
