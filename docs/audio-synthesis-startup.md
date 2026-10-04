# Audio synthesis startup

`src/game/audio/startup/synthesis.c` reconstructs the complete 500-byte routine
at `0x80051A0C..0x80051C00`. It uses the existing 28-byte `AudioSettings` and
36-byte `SdkAudioSynthConfig` layouts. It initializes the eight-message transfer
queue, resets audio state, passes the ROM base token to voice capture, sets the
rate scale, and obtains the SDK output rate before starting the driver.

`storage.c` owns all seven configuration words at `0x8008D828..0x8008D844`
and the runtime state at `0x801901E0..0x80190260`. `buffer_pointers.c` owns
the two command-buffer pointers followed by three RSP-record pointers at
`0x80190180..0x80190194`; `synth_state.c` owns the following 76-byte SDK
synthesizer. `rate_constant.c` owns the four-byte `22050.0f` constant at
`0x80095CC0..0x80095CC4`. Together these declarations generate 32 initialized
bytes and 224 BSS bytes without extra fields or padding variables.

Effect type is truncated to one byte. Type six converts the duration at word
one and the first two words of each eight-word custom-effect row from
milliseconds to samples through the existing delay helper. The conversion
uses single-precision arithmetic, truncates to a signed integer and clears the
lowest three bits. The remaining six words of each row are preserved. Counts
at or below zero still convert the duration and pass the parameter pointer.

The configuration preserves the original partial initialization: the unused
bus-count field, byte padding and parameters for other effect types are not
initialized here. The DMA factory explicitly adapts the existing no-argument
engine factory to the SDK factory type. The matching SDK load-filter
constructor supplies a state pointer; the engine factory ignores that argument.
Adding an unused parameter to the engine definition makes IDO emit an extra
argument-home store, so its already matching declaration is preserved. Guarded
factory cases check initialization and confirm that the state argument is
neither read nor written.

The original frame is 128 bytes, with the configuration at stack offset `0x5C`.
An unused 32-byte local preserves that layout. Its original purpose is unknown;
the source does not claim to recover the original local's name or type. The
instructions leave the entire gap at `0x28..0x5C` untouched.

The source was reconstructed from Robotron's complete instruction range.
Reference projects and analysis tools are credited in [CREDITS](../CREDITS.md).
The independent reference assembly, complete relocation comparison, guarded
execution, Ghidra types and clean build are recorded in the
[proof ledger](audio-synthesis-startup-provenance.json). The execution checker
runs the already matching queue, capture-token, rate-scale and delay helpers;
SDK frequency, driver, reset and control callbacks are recorded ABI boundaries.

`driver.c` reconstructs all 1,308 bytes at `0x80051C00..0x8005211C`. It rounds
the frame's sample count upward, aligns it to sixteen samples, allocates and
clears the voice arrays and DMA pool, links the pool buffers, allocates the two
command buffers and three RSP records, then creates the DMA completion queue
and SDK synthesizer. The common buffer-pointer aggregate reproduces the
observed base address and eight-byte record-array offset. The existing task
selection and task-building functions retain their complete matching bytes.

The driver checker executes the matching heap, byte-clear, link-insertion and
queue helpers against an independent allocation and memory model. It covers
finite rates, rounding boundaries, negative and zero output rates, one- and
multi-buffer pools, zero-sized arrays, and allocation alignment. SDK synthesizer
construction remains a recorded ABI boundary. Heap exhaustion and malformed
zero-buffer counts retain their original behavior and are outside this checker.
