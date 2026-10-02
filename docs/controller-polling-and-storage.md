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

Twelve complete data units add 48 initialized bytes and 1,308 BSS bytes.
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

## Excluded polling candidates

Both complete polling procedures have C candidates:

| Function | Retail bytes | Compiled bytes | Differing words |
| --- | ---: | ---: | ---: |
| Legacy poll `func_8004C1E0` | 408 | 408 | 59 |
| Access-protected poll `func_8004F330` | 424 | 424 | 59 |

A negative incoming argument returns zero without reading the controllers.
A nonnegative argument polls all four ports, rather than selecting one port.
Both paths start the SI read, wait for its message, and unpack the SDK pad
records. The newer path acquires controller access before the read and
releases it after the wait, before unpacking the pad records.

For each connected port, the loop updates current buttons, signed horizontal
and vertical stick words, newly pressed edges, and previous buttons. The
edge expression is `buttons & (buttons ^ previous)`. Disconnected ports keep
their earlier words. Each connected port also overwrites its path's shared
button halfword, so the last connected port wins. The return value is the
zero-extended connection mask. The legacy declaration now uses the integer
return type selected for its reconstructed definition.

The unresolved differences are loop address hoisting, operand/register choices,
and the shared halfword store. Useful cache, declaration, expression, loop,
and compiler-profile probes did not produce an acceptable complete match.
Some private search outputs introduced empty control flow; those were rejected.
The candidates are absent from the matching function manifest and ROM build.
The existing unspecified-argument declaration of `func_8004F330` remains for
its already matching input-mapping caller, which leaves its incoming port in
`a0`. This legacy call is described in
[`controller-input-mapping.md`](controller-input-mapping.md).

The current complete comparisons and source/header/compiler identities are in
[`controller-polling-and-storage-provenance.json`](controller-polling-and-storage-provenance.json).
Remaining polling and Controller Pak work stays tracked in
[issue #39](https://github.com/frankischilling/robotron64/issues/39).

The local libreultra `include/2.0I/PR/os.h` and `src/io/contreaddata.c`
corroborate the SDK pad widths and read/wait/unpack interface. Robotron's
instructions establish both game polling paths and motor behavior. The
requested reference projects remain credited in [CREDITS.md](../CREDITS.md);
no reference implementation or commercial asset is copied into this recovery.
