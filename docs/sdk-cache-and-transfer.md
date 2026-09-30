# Cache, cartridge transfers, and float math

Five complete C procedures recover 1,588 bytes. Five native assembly procedures
recover 720 live bytes, with their zero alignment bytes checked separately.
The target ranges and source extents are recorded in `config/functions.json`.

## Peripheral DMA

The raw extended PI transfer waits until both PI busy bits are clear. The
confirmed handle prefix supplies domain, latency, page size, release duration,
pulse width, and cartridge base address. When the selected handle changes, it
updates only timing registers whose bytes differ from the cached handle, then
updates the domain's cached pointer. RAM addresses use the existing virtual to
physical routine; cartridge addresses combine the handle base and supplied
address before masking to 29 bits. Direction zero writes the PI write-length
register, direction one writes the read-length register, and other directions
return minus one. Hardware setup occurs before the direction check. The
routine uses `sdk-o1-mips2` and retains the original null-handle assumptions.

## Float sine and cosine

Both functions inspect the float exponent and one mantissa bit, reduce bounded
arguments in double precision, and evaluate the confirmed sine polynomial.
Cosine shifts the reduced period by one half. Rounded odd periods negate the
float result. Sine returns sufficiently small inputs directly; both functions
return the existing quiet-NaN value for NaN inputs and zero for sufficiently
large finite values. Signed zero, casts through float storage, and operation
order retain the retail behavior.

The accepted `sdk-o2-mips2-r4300-mul` profile is established by full comparisons.
Its multiply scheduling option supplies the three required multiply-delay
instructions in cosine and the corresponding delays in sine. The existing
polynomial coefficients and reduction constants are reconstructed in
[the float constant recovery](sdk-float-math-constants.md).

## Game buffer and sequence services

Renderer reservation advances the cursor by the requested byte count, reports
overflow through the original diagnostic service, and returns the start of the
reservation. Its diagnostic retains the source-line argument 94.

Sequence binding copies command byte count and signed label count from the
track header into the voice, installs the command buffer, reads the initial
variable-length delay, and installs the label-offset table. Both routines use
the game compiler profile and preserve reloads after calls and indirect stores.

## Native SDK procedures

Data-cache writeback handles addressed 16-byte lines and switches to the full
8 KiB cache for large ranges. Instruction-cache invalidation handles 32-byte
lines and the full 16 KiB instruction cache. Data-cache invalidation writes
back partially covered edge lines before invalidating complete interior lines.
Nonpositive lengths and wrapped address ranges retain their original exits.

Native block clearing aligns the destination, clears 32-byte blocks, then
words and remaining bytes. Interrupt-mask application returns the combined
previous CPU/RCP mask, applies the global interrupt mask, uses the existing RCP
conversion table, and preserves CP0 write delays. These are native SDK assembly
procedures; they are counted separately from recovered C.

## References

The pinned local [libreultra](https://github.com/n64decomp/libreultra) checkout
was consulted for `src/io/epirawdma.c`, `src/io/piint.h`, `src/gu/sinf.c`,
`src/gu/cosf.c`, `src/os/writebackdcache.s`, `src/os/invalicache.s`,
`src/os/invaldcache.s`, `src/os/setintmask.s`, and `src/libc/bzero.s`.
Robotron's complete linked instructions determine the accepted profiles,
addresses, register use, and retained behavior. [CREDITS.md](../CREDITS.md)
records the full local and online reference collection.

## Verification

All 680 runtime units, both startup units, and seventeen assembly units pass
complete independent comparisons. All 114 tooling tests pass, and the linked
8,388,608-byte ROM matches the normalized target. The
[provenance ledger](sdk-cache-and-transfer-provenance.json) records source and
input identities for the ten new units. These are historical identities;
current progress requires rebuilding and comparing the current checkout.
