# Executable inventory

Run `make analysis-setup` followed by `make analyze` in Linux or WSL. The optional environment pins spimdisasm 1.42.4 and rabbitizer 1.16.2. Analysis validates the target ROM before writing local disassembly, symbol context, function records, and a JSON summary under `build/analysis/`. These generated files stay outside Git.

The candidate CPU interval is ROM `0x1000..0x70040`, mapped to `0x80000400..0x8006F440` (ends exclusive). The disassembler reports 1,536 records covering 454,720 bytes. These are provisional records, not verified function boundaries or a code-size denominator. Padding, internal data, and merged functions still need review. Matching progress does not use these counts.

## RSP boot boundary

At CPU addresses `0x80050198..0x800501D0`, task initialization forms pointers `0x8006F440` and `0x8006F510`, subtracts them, and stores the start and length. Another initialization sequence at `0x800522BC..0x800522FC` uses the same pair. Their difference is `0xD0` bytes.

Using the initial mapping, these bytes occupy ROM `0x70040..0x70110`. RSP disassembly starts with a jump to `0x04001064`. It loads task fields through DMEM address `0xFC0`, performs transfers through SP memory/DRAM/length registers, polls DMA status, and transfers control to `0x1080`. This supports identifying the region as RSP boot code, with CPU storage at `0x8006F440` and RSP execution at `0x04001000`.

The linker now isolates this region from the candidate CPU fallback. The rest of the ROM retains a synthetic link address until its mapping is established. Splitting fallback regions does not increase reconstructed-source progress.

## Remaining work

Review candidate boundaries against callers, returns, jump tables, and data references. Identify the RSP programs following the boot region and trace their selection. Establish initialized-data boundaries before claiming a complete executable map.
