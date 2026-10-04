# Audio voice release and pitch commands

`func_8005B854` scans hardware voice records belonging to a sequence voice.
It captures eligible notes through the existing capture helper, then applies
the existing timed-release helper until the hardware-voice budget is exhausted.
Its complete function covers 420 instruction bytes. The private state occupies
all 16 bytes at `0x80192AD0..0x80192AE0`.

`func_8005BA24` decodes the command's signed 16-bit pitch bend. An unchanged bend
only updates the private command value. A changed bend updates the voice and
visits its active hardware records. Positive and negative bend use the region's
separate signed factors, double `0.0122` and conversion to integer cents. Key,
root key, wave tuning and signed detune supply the remaining pitch adjustment.
The existing pitch helper computes the scale passed to the SDK voice setter.
The complete function covers 676 instruction bytes; its private state occupies
24 bytes at `0x80192AE4..0x80192AFC`, including two preserved padding bytes.

The pitch command owns the complete 16-byte constant section at `0x80095CE0`:
one eight-byte double followed by eight zero alignment bytes. The existing
pitch helper's two float factors remain at `0x80095CC4..0x80095CCC`, now defined
in `src/game/audio/pitch_factors.c` so the visible helper body contributes no
duplicate constant section.
IDO emits these named constant floats in `.data`; the linker retains their
existing retail address and complete eight-byte range.

IDO uses the visible capture and pitch helper definitions when deciding which
state a call can change. Each new source includes its already recovered helper.
The existing strict text partitioner retains the complete new function without
changing its MIPS instructions; the separate helper object still owns its body.
The original translation-unit boundaries remain unknown. Complete comparisons
of the discarded 316-byte capture and 100-byte pitch definitions are required
alongside the new functions. The pitch unit uses the verified game profile with
the R4300 multiplication workaround.

Ghidra MCP, retail disassembly, typed m2c, asm-differ, objdiff and targeted
permuter experiments support this reconstruction. Retail references are
independently assembled from splat/spimdisasm output. No reference-game source
was copied. The tools are credited in [CREDITS.md](../CREDITS.md).

`tools/check_audio_voice_commands.py` checks 296 release cases and 476 pitch
cases against retail instructions and independent byte models. Both images
execute the real capture, timed-release and pitch helpers. Cases cover empty
and exhausted pools, ownership filters, capture categories and capacity, signed
bend and region factors, clock and release-time wrap, callback changes to the
cursor, counters and live fields, and the current output-rate multiplier.
Each SDK boundary checks a complete state snapshot. The checker also checks
every buffer and guard, bounds memory accesses, poisons caller-saved registers,
and verifies integer and floating callee-saved registers, stack preservation,
private padding and FCSR rounding and condition bits.

SDK setters use recorded stubs; synthesis and hardware execution are outside
this checker. Numeric fixtures cover finite pitch with round-to-nearest
arithmetic. Invalid pointers, negative capture indices and unbounded invalid
pool scans are outside scope.

Objdiff's linked text views report 100 percent for both complete functions.
The raw objects report 98.71429 and 98.93491 percent because their relocation
symbols differ. The linked viewer uses byte-checked text-only copies; objdiff
could not read the pitch image with its linked data sections. Production objects
and untouched IDO output retain their other sections. Independent data, BSS,
relocation and execution comparisons verify the complete ownership separately.
Both constant ranges were also independently disassembled and reassembled.

Clean extraction and build reproduce all 8 MiB of the target ROM. Fresh checks
pass two startup blocks, 888 runtime blocks, eighteen assembly units, 115
data-only units and 163 tooling tests. Existing seeking, tick and playback
checks also pass. The [proof ledger](audio-voice-commands-provenance.json)
records their exact input hashes and results.

These two functions add 1,096 matching C bytes, sixteen initialized bytes and
forty BSS bytes. The measured checkpoint contains 1,406 matching C functions
and 289,464 C bytes. The candidate CPU range still contains 160,720 fallback
bytes across 196 spans, plus 164 unclassified bytes. Full-ROM equality includes
those fallbacks and does not establish source completion.
