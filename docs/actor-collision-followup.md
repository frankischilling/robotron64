# Collision rebound and retirement

`src/game/collisions/rebound.c` recovers `func_8001631C` at
`[0x8001631C, 0x80016618)`: all 764 instruction bytes, the 56-byte frame
and its generated eight-entry, 32-byte table at `0x8008FEE8` match.
`retire.c` recovers `func_8001B4F8` at `[0x8001B4F8, 0x8001B7D0)`:
all 728 instruction bytes, the 32-byte frame and its generated 36-entry,
144-byte table at `0x800902D4` match. `retirement_message.c` owns the
28-byte diagnostic at `0x80090200`, including its terminating zero.
Each complete range is independently compiled with pinned IDO 5.3.

The rebound callback is selected for collision matrix kinds one and four.
Kinds eight, nine and thirteen return zero. Kinds fourteen and fifteen
select animation three, cancel the current callback when enabled, and
install the mode-zero callback with timer 999. Kind eleven reaches the
shared collision path only for second-actor resource kinds one and two.
The remaining kinds return 32 when the second actor has flag `0x100`.

Kind twelve conditionally plays sound 84, clears that flag, and takes
the signed random result shifted right by three modulo 4,096. It stores
the narrowed direction, sets seven tenths of resource speed, and computes
each movement component as the wrapped trigonometric product times seven
times speed, divided by ten and then 4,096. These are signed divisions
rounded toward zero. The source preserves multiplication order and fresh
resource, direction and object-index reads after service calls.

The shared path calls the existing collision damage service. A depleted
first actor receives score handling in modes other than minus one and
then the turn service. A surviving actor creates effect 19 at the signed
midpoint, with Z zero. The callback returns 32 only when the second actor's
health is exactly zero; negative values retain the zero result.

The result is an integer local returned as an unsigned byte. Retail loads
the final byte from stack offset `0x2B`. The existing matrix casts this
callback to its integer-returning interface; its MIPS ABI receives the
zero-extended value. That cast does not establish ISO C function-type
compatibility. The goto into the shared default branch reproduces retail's
branch into another branch's delay-slot instruction. Swapping the two
midpoint operands resolves four load-order differences without changing
their wrapped sums or signed division.

The retirement handler clears health and increments a signed counter
when mode is other than minus one. The canonical pool prefix now calls
the 36 halfwords at offset `0x50` `retiredBehaviorCounts`; the existing
72-byte reset and the recovered indexed read/increment/store establish
this view. It remains part of the known 500-byte prefix, with no claim
about the complete allocation or valid caller indices. Counter ownership
remains separate from the function and initialized-data recovery.

Retirement preserves kind-four creation before the common reset/label
path, scatter and object effects, timer-one callback installation for
kinds seventeen through twenty, and the optional related actor's impulse
pointer for kinds twenty-five through twenty-eight. It cancels callbacks
and installs the final timer-999 callback according to the resource kind
read after intervening calls. Kind five skips animation and zero-motion
setup; other kinds retain both trigonometry calls even though their
results are discarded. Unknown kinds reach the diagnostic service.
The gate's retirement declaration now uses the verified actor-pointer
second argument; its compiled instructions remain identical.

`python tools/check_actor_collision_followup.py` freshly compiles both
callbacks, both generated tables and the diagnostic, then checks retail
and compiled execution in 2,570 cases against independent arithmetic,
call-order and guarded-state oracles. These include signed counter
overflow, every switch kind, a null impulse source, callback replacement,
resource and flag changes, signed random extremes, wrapped products,
negative and overflowing midpoint sums, exact-zero returns and argument
home stores. Integer caller-saved and floating-point caller registers are
clobbered at service boundaries; the stack and integer callee-saved
registers are checked on return. All called services use ABI stubs.
These checks do not establish real callee effects or complete gameplay.
Invalid retirement kinds are tested with counter updates disabled.
The preceding gate/pickup checker also passes all 3,636 cases with the
current header and refined retirement declaration.

Ghidra MCP imported the canonical pool layout, applied both callback
signatures and saved the analysis. The rebound body was initially
degenerate; explicit disassembly and the next verified function bound
recover all 191 instructions. A residual decompiler warning concerns
the shared delay-slot instruction. Complete raw bytes and MIPS control
flow establish the accepted result. Ghidra memory reads agree with every
recovered instruction, table and diagnostic byte.

Private splat/spimdisasm output was independently assembled and linked
at the verified instruction and table addresses. Both objdiff function
comparisons reach 100%; fresh complete byte comparisons remain the
acceptance evidence. m2c also reads the complete reference tables with
the final IDO context. asm-differ and the fresh matching workbench compare
the accepted sources. Extracted assembly, reference objects and tool
output remain in ignored directories. Tools and references are credited
in [CREDITS.md](../CREDITS.md).

The larger callback at `0x8001567C` remains a private nonmatching candidate,
along with the separate damage candidate. Neither contributes source
ownership or matching progress. [Issue #43](https://github.com/frankischilling/robotron64/issues/43)
tracks remaining early actor work. The [provenance ledger](actor-collision-followup-provenance.json)
records complete comparison, input, object-layout, execution and
clean-build evidence. Whole-ROM equality includes fallback; this
checkpoint does not establish full decompilation.

The combined callback and rotation checkpoint passes isolated extraction and
clean rebuild, all 8,388,608 ROM bytes, all 152 tooling tests, and independent
comparisons for 865 runtime, two startup, eighteen assembly and 100 data-only
units. Matching C totals 1,383 procedures / 272,616 instruction bytes;
initialized ownership is 30,063 bytes and BSS ownership is 504,115 bytes.
The provisional CPU range still has 177,580 fallback bytes in 210 ranges and
152 unclassified bytes. Complete executable and function denominators remain
unverified.
