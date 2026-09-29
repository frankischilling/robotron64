# Audio filter construction

Seven complete procedures reconstruct 732 bytes of the synthesizer's filter
construction code. The six specialized constructors form the full 704-byte
unit at `0x8006B5E0..0x8006B8A0`. The shared 28-byte constructor is at
`0x8006E750..0x8006E76C`.

| Function | Filter | Object offset | Live bytes |
| --- | --- | ---: | ---: |
| `func_8006B5E0` | Output save filter | `0x000` | 68 |
| `func_8006B624` | Main bus | `0x044` | 84 |
| `func_8006B678` | Auxiliary bus | `0x098` | 84 |
| `func_8006B6CC` | Resampler | `0x0EC` | 136 |
| `func_8006B754` | Sample decoder | `0x174` | 168 |
| `func_8006B7FC` | Envelope mixer | `0x21C` | 164 |
| `func_8006E750` | Shared filter record | `0x000` in its own unit | 28 |

The shared constructor stores the processing callback, parameter callback,
and filter type, then clears the source pointer and input/output fields. The
specialized constructors select those callbacks and initialize the fields
required by their respective processing stages.

The save filter starts with no DRAM output address and its first-frame flag
set. Both buses store their source-array pointer and capacity and begin with
no connected sources. The resampler allocates its 32-byte state, initializes
a one-to-one ratio, and clears motion, fractional position, unity-pitch mode,
and queued updates.

The decoder allocates separate 32-byte current and loop states. Its DMA
factory receives the address of the decoder's DMA-context pointer and returns
the decoder's DMA callback. The decoder then initializes its sample cursor,
first-block flag, and input address. The envelope mixer allocates an 80-byte
state and initializes its volume targets, current channel levels, routing
amounts, timing fields, and update-list pointers.

Only the fields written by the target are initialized. In particular, the
envelope constructor writes the left rate fields without adding corresponding
right-rate stores, and neither state allocation gains a new failure check.
These details remain visible in the reconstructed C and the complete byte
comparisons.

## Records and verification

`include/sdk_audio_pipeline.h` extends the shared SDK audio declarations with
the 28-byte save filter, 32-byte bus, 44-byte effect record, and 76-byte auxiliary
bus. Compile-time size checks cover every new record. The existing decoder,
resampler, envelope, and state layouts remain defined in `sdk_audio.h`.

IDO 5.3's `sdk-o3-mips2-r4300-mul` profile reproduces all 732 code bytes with
zero differing words. The constructors are declared in their natural source
dependency order; the compiler emits the six specialized procedures in the
target order listed above. Actual ELF symbol offsets and sizes are checked
for every procedure. These units emit no initialized data, constant tables,
or BSS. The shared constructor has four trailing alignment bytes beyond its
28-byte procedure; the existing padding verifier checks them before removal.

Both units have canonical registrations in `tools/compare_runtime.py`, fixed
ROM placements in the production linker, and current source/header/compiler
provenance checks. The target instructions and the synthesizer's existing
callers establish the reconstruction. The earlier
[audio filter study](sdk-audio-filters.md) and [CREDITS.md](../CREDITS.md)
record the N64 interface references; the constructor sources described here
are reconstructed from Robotron's target procedures.
