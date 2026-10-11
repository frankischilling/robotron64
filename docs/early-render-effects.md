# Early tube and star rendering

The retail code contains two animated tube routines followed by the star fan
used by the already recovered color presets. This checkpoint reconstructs
their C behavior and owns their shared initialized state. All three procedures
remain nonmatching candidates, excluded from the matching build and progress
totals. Their complete retail extents remain in the ROM fallback.

| Procedure | Retail extent | Retail bytes | Compiled bytes | Differing words | Role |
| --- | --- | ---: | ---: | ---: | --- |
| `func_8000B1E4` | `0x8000B1E4..0x8000B5AC` | 968 | 960 | 158 | Eight quads per band; moving depth |
| `func_8000B5AC` | `0x8000B5AC..0x8000B964` | 952 | 952 | 146 | Sixteen quads per band; advancing rotation |
| `func_8000B9D4` | `0x8000B9D4..0x8000BE80` | 1,196 | 1,196 | 281 | Alternating-radius star fan |

Both tubes prepare an identity matrix, apply the shared Z rotation, transform
their camera-relative position, and submit the resulting draw matrix. The
first increments depth by 1,000, resets it above 32,000, and uses the old depth
for this frame. The second advances the shared angle by sixteen after building
its rotation matrix. Both draw sixteen bands, beginning at depths 100 and 2,100
and moving each band forward by 2,000.

Each quad writes four 16-byte vertices with alpha 128. The palette index begins
at the band number and advances for each quad; the two other corner colors use
the following palette entries. Position calculations use the recovered
4,096-unit trigonometric helpers, a radius of 1,000, and arithmetic right shifts
by twelve. The eight-quad routine advances angles by 512; the sixteen-quad
routine advances them by 256.

The routines clear geometry bit `0x2000`, draw, then set it again. The supplied
libreultra 2.0I GBI header identifies that bit as `G_CULL_BACK`. The four-vertex
load is `0x0400103F`, followed by `0xB1020406 / 0x00020600`. This is consistent
with the older F3DEX command layout; the selected game microcode remains under
investigation. An exhausted vertex allocator returns after the clear command,
without emitting the final set command. The reconstructed source preserves
that path and the retail cumulative band accounting.

The star fan resolves the actor's signed object index into the 120-byte object
array. It transforms that object's position relative to the camera and writes
the projected position at object offset `0x60`. Mode controls twice as many
perimeter vertices. Radius starts at 120 and is multiplied by a random value
between 100 and 115, then divided by 100. Brightness is randomized between 200
and 255 unless actor field `0x4C` forces 255. Odd perimeter vertices use twice
the radius. The center receives scaled RGB and alpha 255; the retail perimeter
stores only scaled red and sets its other color bytes to zero. The final fan
triangle wraps to perimeter vertex one. Allocation failure returns one;
successful submission returns zero.

The shared data unit owns 104 initialized bytes at `0x800730D8..0x80073140`:
two initially zero integer words and eight RGB triples. IDO emits an ordinary
writable data section. Ownership trims only its trailing alignment zeros and
checks all three symbol offsets, the complete section bytes, and the linked
placement. The next initialized word is outside this unit.

`python3 tools/compare_runtime.py --candidates --jobs 6` compiles the three full procedure
extents using the existing IDO 5.3 game profile. Stack layout, induction
variables, register assignment, and scheduling still differ. Equal output
lengths do not establish a match. The complete candidate and data results are
recorded in `early-render-effects-provenance.json`, including current source,
header, compiler, and layout input hashes. No candidate contributes executable
bytes to the rebuilt ROM.

## Tube execution and remaining compiler differences

`make check-early-render-tubes` freshly compiles both complete candidates,
twelve matching support units, and the 104-byte tube state and palette. The
guard executes retail and candidate MIPS code without ABI stubs. Independent
oracles check the entire 22,000-vertex pool, display-list commands and canaries,
the complete SDK matrix arena, depth and rotation state, trigonometric call
arguments, cumulative commits, stack bounds, and saved integer registers.

The 320 paired cases cover both segment counts, allocator positions zero and
seven, the 9,800-vertex threshold and its warning path, a high valid allocation,
four rotation inputs, unchanged and departing mode 18, both matrix buffers,
identity and skewed view matrices, and depth values zero, 31,000, 31,001 and
32,000. Fourteen freshly compiled mutation controls must fail: radius, palette
mask, alpha, quad command, cumulative count and band limit for each helper,
plus moving-depth wrap and advancing rotation. Receipts include current source,
header, compiler, layout, guard and emulator provenance.

The per-band commit uses the original first vertex throughout the function.
It submits cumulative counts of 32 through 512 for the narrow tube and 64
through 1,024 for the wide tube. Consequently the allocator advances by 4,352
and 8,704 respectively while the vertex cursor advances by 512 and 1,024. This
is observed retail behavior, preserved by the candidate and checked explicitly;
it is not an invitation to change the game algorithm.

The wide candidate captures the allocator result in the local first-vertex
value and shares RGB byte assignments between corners one and three. Its
natural body now has the retail length, but 146 words still differ. The stack
frame is 288 bytes versus retail's 328 bytes. The narrow candidate remains
960 bytes with 158 differing words. No unused local, extra parameter, enlarged
draw record or instruction patch was introduced to force a match. The verified
60-byte draw prefix does not prove the original caller's complete stack layout.

Private research compared 85 directed compiler forms and freshly recompiled all
123 retained outputs from a bounded decomp-permuter run with stack checking.
Review found changed external declarations, loop-counter overwrites, and reads
of uninitialized coordinate locals. The lowest complete word difference, 144,
overwrites the band counter with a palette value; using the retail palette it
draws two bands instead of sixteen. It is rejected. Independent splat and
spimdisasm references reproduce both complete retail tube ranges; typed m2c
and the saved Ghidra analysis supply additional control-flow evidence.

The execution guard covers finite CPU fixtures. It does not execute the RSP or
RDP, prove gameplay, establish original local declarations, or grant instruction
ownership. Both tube routines remain excluded from the matching ROM build and
progress totals. Original stack storage, induction variables and scheduling
still need recovery before their fallback extents can be replaced.

The target ROM supplies all Robotron-specific behavior. The local libreultra
GBI header supplies command-format and geometry-bit definitions. Existing
matching matrix, trigonometric, object, and vertex-arena sources supply the
checked caller layouts. No implementation was copied from another game.
