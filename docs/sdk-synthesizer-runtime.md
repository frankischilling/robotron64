# Synthesizer initialization and command generation

`src/sdk/audio_synthesizer.c` reconstructs the complete 1,760-byte unit at
`0x80065C30..0x80066310`, together with 16 bytes of compiler-generated
constants at `0x80095E50..0x80095E60`. Its seven public procedures and two
private timing helpers all have complete compiled-byte and procedure-extent
proofs.

| Procedure | Purpose | Object offset | Live bytes |
| --- | --- | ---: | ---: |
| `timeToSamplesNoRound` | Private unaligned sample conversion | `0x000` | 8 |
| `func_80065C38` | Convert time to a 16-sample-aligned count | `0x008` | 88 |
| `func_80065C90` | Queue a physical voice for release | `0x060` | 56 |
| `func_80065CC8` | Move pending releases onto the free list | `0x098` | 96 |
| `func_80065D28` | Return a parameter record to the free list | `0x0F8` | 24 |
| `func_80065D40` | Allocate a parameter record | `0x110` | 48 |
| `nextSampleTime` | Private earliest-client selection | `0x140` | 8 |
| `func_80065D78` | Generate an audio command frame | `0x148` | 664 |
| `func_80066010` | Initialize the synthesizer and filter graph | `0x3E0` | 768 |

## Initialization and state lists

Initialization records the output rate, DMA factory, physical-voice count,
and a 160-sample output-block limit. It allocates and connects the save filter,
main bus, and auxiliary bus. A configured effect is inserted on the effect
path; without an effect, the main bus is connected directly to the auxiliary
bus.

Every physical voice receives a decoder, resampler, and envelope mixer. The
decoder's source is initially null, the resampler consumes the decoder, and
the envelope consumes the resampler. The envelope is added to the auxiliary
bus and becomes the physical voice's channel interface. Physical voices begin
on the free list. The update pool is built as a singly linked list of 28-byte
parameter records.

Parameter allocation removes the first record, clears its next pointer, and
returns null when the pool is empty. Returning a parameter prepends it to the
pool. Voice release first places the voice on the pending-free list; frame
completion moves every pending node to the reusable free list. The target's
heap-allocation behavior is preserved, including its unchecked allocation
results during initialization.

## Timing and audio frames

The earliest-client helper scans callback clients using each client's sample
deadline relative to the synthesizer's current sample. It preserves the
target's first-minimum selection and reloads the deadline after updating the
selected-client pointer. Its caller assumes that the client list is nonempty;
the frame function checks for an empty list before invoking it.

The time conversion first multiplies the microsecond count and output rate
as single-precision values. It then divides in double precision by one million,
adds one half, converts back to single precision, and truncates to an integer.
The public conversion clears the low four bits. The callback deadline update
uses the unaligned count, while the parameter timestamp is aligned before
each callback and again before producing output.

Frame generation invokes callbacks whose deadlines fall within the requested
sample interval. It then generates blocks of at most 160 samples. Each block
begins with the segment-zero audio command, sets the save filter's DRAM output
pointer, and invokes the output graph with the current sample count. The
stereo output pointer advances by two samples per produced frame. Completion
returns the command cursor, reports the number of eight-byte commands, and
recycles pending physical voices.

`sdk_audio_commands.h` evaluates a command cursor once when constructing a
packet, including when the caller passes a post-increment. The separate
current-packet and returned-command cursors preserve the target's address
lifetimes across the filter callbacks. The filter records and their creation
procedures are documented in [audio filter construction](sdk-audio-filter-construction.md).

## Full code and generated-data proof

IDO 5.3 with `sdk-o3-mips2-r4300-mul` reproduces all 1,760 code bytes and the
16-byte constant section, with no differing words. The constants occupy ROM
`0x96A50..0x96A60`; the code occupies ROM `0x66830..0x66F10`. The unit emits
no initialized writable data or BSS.

Both private timing algorithms are written as ordinary C functions. IDO
inlines them into their callers and retains the original eight-byte procedure
remnants. Their identities, offsets, and sizes are verified through paired
ECOFF static-procedure and end records, independently of the public ELF
symbols. Their manifest entries retain static linkage, and their former
absolute fallback aliases are removed. No synthetic padding or empty source
function replaces either algorithm.

The initialization declaration sequence is corroborated by the pinned SDK
reference's historical virtual-voice declarations. The reference studies also
establish the packet-cursor convention and timing interfaces; the target
instruction stream establishes the accepted code and constants. See the
libreultra entry in [CREDITS.md](../CREDITS.md) and the earlier
[audio frame study](sdk-audio-frame.md). The original reference-adapted source
is retained only as private research.
