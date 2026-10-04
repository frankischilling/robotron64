# Controller polling, duty update, and storage

`src/game/controller/motor_duty.c` replaces the complete 272-byte procedure
at `0x8004F850..0x8004F960`. The pinned IDO 5.3 game profile reproduces every
instruction. The audio thread calls this routine for message kind one.

Only port zero is modulated. If that port has no motor, the routine does
nothing. Strength above 70 requests a start when the motor is inactive;
strength below 6 requests a stop when it is active. Intermediate strength
uses the shared phase word. A phase of at least 256 subtracts 256 and
requests a start if needed. Otherwise the phase gains
`strength * strength * strength / 512 + 4`, and an active motor receives a
stop request. The signed division, low-word multiplication, thresholds,
and command order follow the retail instructions.

The local port index selects the first motor consistently throughout the
update. A bounded private search helped identify this source form. The
accepted source removes the search's unused phase variable and uses literal
zero for the active-state comparisons. It retains no dummy variable, empty
conditional, instruction patch, or inline assembly.

## Storage ownership

The earlier storage recovery added 48 initialized bytes and 1,308 BSS bytes
across twelve complete data units.
Their compiled symbols, section sizes, and linked addresses are compared
independently. The access message and queue use separate data units to
retain their four-byte spacing; compiling them together introduces an
eight-byte spacing in IDO. Unproved gaps remain outside their ownership.

| Storage | RAM range | Bytes |
| --- | --- | ---: |
| Connected-controller and Pak masks | `8013D9D0..8013D9D2` | 2 BSS |
| Four 104-byte SDK Pak records | `8013D9D8..8013DB78` | 416 BSS |
| Selected Pak file index | `8013DB78..8013DB7C` | 4 BSS |
| Motor command | `80143418..80143420` | 8 BSS |
| Access message and queue | `80143424..80143440` | 28 BSS |
| Last polled button halfword | `80143440..80143442` | 2 BSS |
| Pak directory, results, decoded name, status | `80143450..801437A0` | 848 BSS |
| Access-initialization guard | `8008D504..8008D508` | 4 initialized |
| Motor strength | `8008D510..8008D514` | 4 initialized |
| Initialization diagnostic | `80095BB0..80095BC4` | 20 initialized |
| Refresh diagnostic | `80095BC8..80095BDC` | 20 initialized |

The directory unit contains sixteen 32-byte SDK file-state records, sixteen
integer results, a 256-byte decoded-name buffer, and four 4-byte controller
status records. The existing matching directory loop and name-buffer clear
establish these bounds. The two diagnostic arrays contain the same surviving
message, `motor present on %d\n`; the four alignment bytes after each remain
fallback. The zero guard and strength remain initialized data, as in the ROM.
The legacy encoded-name buffer at `8013DC10` still has an unresolved capacity
and receives no new ownership claim.

## Complete polling procedures

Both procedures now have complete matching C sources and replace their entire
fallback ranges. Each owns its existing two-byte function-local static word.

| Function | Retail bytes | Compiled bytes | Differing words |
| --- | ---: | ---: | ---: |
| Legacy poll `func_8004C1E0` | 408 | 408 | 0 |
| Access-protected poll `func_8004F330` | 424 | 424 | 0 |

A negative incoming argument returns zero without reading the controllers.
A nonnegative argument polls all four ports, rather than selecting one port.
Both paths start the SI read, wait for its message, and unpack the SDK pad
records. The newer path acquires controller access before the read and
releases it after the wait, before unpacking the pad records.

For each connected port, the loop updates current buttons, signed horizontal
and vertical stick words, newly pressed edges, and previous buttons. The
edge result is `buttons & (buttons ^ previous)`. The source computes it from
the freshly assigned current-button word and the previous word. Disconnected ports keep
their earlier words. Each connected port also overwrites its path's shared
button halfword, so the last connected port wins. The return value is the
zero-extended connection mask. The legacy declaration now uses the integer
return type selected for its reconstructed definition.

The matching sources assign a function-local `static unsigned short
polledButtons` before updating the arrays, then snapshot it in the local
integer button value. IDO schedules the halfword store after each enabled
port's array updates. The static declaration and edge expression account for
the earlier loop-hoisting and operand differences without volatile storage,
empty conditionals or unused stack declarations. This source form reproduces
the instructions; it does not establish a unique original declaration.

Ghidra's recorded references to `8013DC08` and `80143440` contain only the two
unrolled stores inside each corresponding poll. The legacy word moves out of
`controller_pad_state.c`, whose six arrays now own 104 bytes. The protected
word moves out of its separate data-only source. Both polls' raw BSS sections
are 16 bytes, but only the measured two-byte objects are retained. IDO debug
records establish their private names and offsets independently of compiler
symbol suffixes. Total BSS ownership stays unchanged; this recovery adds
832 C bytes and removes two complete fallback ranges.

The existing unspecified-argument declaration of `func_8004F330` remains for
its already matching input-mapping caller, which leaves its incoming port in
`a0`. This legacy call is described in
[`controller-input-mapping.md`](controller-input-mapping.md).

`tools/check_controller_polling.py` freshly compiles and links both procedures
and the pad-state data unit, then checks 3,158 guarded cases per poll against
the retail instructions and a separate memory oracle. Cases cover every
eight-bit connection mask, negative and arbitrary nonnegative arguments,
individual button bits, wide previous words, signed stick limits, nonzero SDK
error bytes, repeated buttons and disconnected-port preservation. Support
boundaries check protocol order, queue/pad arguments and complete memory
images while clobbering caller-saved registers and HI/LO. Read/write guards,
stack guards and saved integer registers are checked. The SDK and access
services are stubs in this check; actual hardware, synchronization and
full-game input remain outside its scope.

Independent assembly reassembly, object comparison, fresh matching and
asm-differ cover both complete functions. The reference represents each
verified scratch range with a local BSS label to compare the compiler's
section relocation; linked retail bytes are checked before the raw object
comparison. Both functions have 100% object comparisons.

Ghidra uses the canonical six-byte SDK pad and 24-byte message-queue types
and integer poll signatures. Its current sparse memory map does not permit
applying the pad array at `8013DBA0` or either BSS halfword. Those limitations
are recorded in the analysis proof rather than treating the globals as applied.

The current complete comparisons and source/header/compiler identities are in
[`controller-polling-and-storage-provenance.json`](controller-polling-and-storage-provenance.json).
Remaining controller and Controller Pak work stays tracked in
[issue #39](https://github.com/frankischilling/robotron64/issues/39).

The local libreultra `include/2.0I/PR/os.h` and `src/io/contreaddata.c`
corroborate the SDK pad widths and read/wait/unpack interface. Robotron's
instructions establish both game polling paths and motor behavior. The
requested reference projects remain credited in [CREDITS.md](../CREDITS.md);
no reference implementation or commercial asset is copied into this recovery.
