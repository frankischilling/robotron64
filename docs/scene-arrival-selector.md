# Scene arrival selector

`func_80021C3C` accumulates active arrivals from categories 0, 1 and 3 into
a 360-word local table. Trigger 0 takes the maximum of count plus delay;
trigger 2 takes the maximum delay; other triggers add the signed count.
The sign flag expands four category-3 counts by three. Two category-0 ranges
use the existing scaling globals. Resource groups are visited in retail order,
with selection gated by half the signed animation length.

The complete function occupies `80021C3C..80022044` (1,032 bytes). Its generated
six-entry switch table occupies `80091A08..80091A20` (24 bytes). Twelve zeros
following the return remain fallback. The 10-by-36 local count table retains
all 1,440 bytes. A one-element pointer holder stores the address of the first
argument's stack home, and every conditional copy uses that element. Retail
writes that argument home rather than the caller's output buffer; the C source
preserves the observed indirection. The four-iteration glyph loop is naturally
unrolled by pinned IDO 5.3 with the existing game compiler profile.

`make audit-scene-arrival-selector` freshly compiles the selector and three
supporting C units. Complete code and generated data must match before paired
retail and source executions check 191 fixtures against a separate integer
model. The audit checks all 360 count words, resource and call ordering,
signed arithmetic, argument-home writes, unchanged caller memory, guarded
guest access and preserved integer and floating-point registers. Sixteen guest
faults are each bracketed by passing executions. Every called helper runs its
actual instructions; no returning call is simulated.

Separate Splat and spimdisasm reference objects independently reproduce the
complete code and switch table. Ghidra supplies function bounds, caller types,
resource layouts and the conditional-copy signature. m2c, asm-differ, objdiff
and read-only IDO diagnostics supported source refinement. References and tool
credits are in [CREDITS.md](../CREDITS.md). Finite synthetic fixtures do not
establish complete gameplay or arbitrary malformed inputs. Full-ROM equality
still includes remaining fallback regions.
