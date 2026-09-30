# Controller initialization and refresh

`src/game/controller_service_setup.c` recovers both procedures in the
contiguous range `0x8004F4D8..0x8004F850`. Initialization accounts for 476
instruction bytes and refresh for 412, giving 888 bytes of complete C source.
The pinned IDO 5.3 game profile reproduces the full object independently.

Initialization creates the SI and motor command queues, binds event five to
the SI queue, creates thread eight with priority fifteen, and starts it. The
thread uses the existing 1,024-element 64-bit stack. Its top has the same
address as the adjacent controller status buffer; these remain separate source
objects. The code then initializes controller status and queries Pak presence.

Both routines visit all four ports. Each visit clears the motor availability,
active motor, and pending operation words before testing that port's Pak bit.
A present Pak is passed to the SDK Pak initializer. Results ten and eleven
clear its Pak bit and attempt motor initialization. Initialization does this
for every port. Successful motor initialization prints the target diagnostic
and sets the corresponding availability word.

Refresh restricts motor initialization to port zero. Its return value starts
at zero, becomes one when port zero has a usable Pak, minus two when motor
initialization succeeds, or minus one when that attempt fails. An absent port
zero leaves the result zero. The code preserves the target's repeated
controller initialization call, ignored return values, and per-port state
clearing.

The bit expressions remain at their use sites. Their complete object match
includes the original pointer induction, mask reuse, branch delays, and
register allocation. No stack padding, inline assembly, or executable fallback
inside these procedures is used.

The local libreultra controller and Pak declarations, and Perfect Dark's
controller initialization source, support the SDK layouts and API names. The
Robotron ROM determines these game routines' behavior. All thirteen requested
reference projects and their inspected revisions are credited in
[CREDITS.md](../CREDITS.md). This recovery adds no initialized storage or BSS
ownership within the executable object.

Two complete data units recover its motor flags and thread state. The motor
availability and pending operation arrays occupy 32 initialized bytes, all
zero in the supplied ROM. The thread state occupies 8,712 BSS bytes from
`0x80141210` through `0x80143418`: two 24-byte queues, two message words, the
432-byte thread, its 8,192-byte stack, four controller status records, and four
active motor words. The compiled symbols reproduce every boundary. The
compiler's unused BSS tail alignment is excluded from live ownership. The
diagnostic strings retain their existing fallback ownership.
