"""Compare the excluded text replacement candidate with the validated ROM.

Append the candidate to the integrated text source to share recovered types and
prototypes without adding it to the production build or progress count.
"""

import json
from pathlib import Path
import subprocess
from rom import ROOT, validate
from toolchain import install


def run():
    target = (ROOT / 'baseroms/us/baserom.z64').read_bytes()
    validate(target)
    install('5.3')
    directory = ROOT / 'build/text-replacement-comparison'
    directory.mkdir(parents=True, exist_ok=True)
    source = directory / 'candidate.c'
    source.write_text((ROOT / 'src/game/text.c').read_text() + '\n' +
                      (ROOT / 'src/game/text_replacement.c').read_text())
    obj = directory / 'candidate.o'
    subprocess.run([str(ROOT / '.local/toolchain/5.3/cc'), '-c', '-O2', '-G', '0',
                    '-non_shared', '-mips1', '-32', '-o', str(obj), str(source)],
                   check=True, cwd=ROOT)
    script = directory / 'candidate.ld'
    definitions = (ROOT / 'linker_scripts/us.ld').read_text().split('SECTIONS')[0]
    script.write_text(definitions + '''SECTIONS {
.text_start 0x80000450 : { *(.text) }
.text_table 0x8008F678 : SUBALIGN(4) { *(.rodata) }
/DISCARD/ : { *(.reginfo .MIPS.abiflags .mdebug .mdebug.*) }
}
''')
    elf = directory / 'candidate.elf'
    subprocess.run(['mips-linux-gnu-ld', '-T', str(script), '-e', 'func_80000F48',
                    '-o', str(elf), str(obj)], check=True, cwd=ROOT)
    binary = directory / 'text.bin'
    subprocess.run(['mips-linux-gnu-objcopy', '-O', 'binary', '-j', '.text_start',
                    str(elf), str(binary)], check=True)
    symbols = subprocess.check_output(['mips-linux-gnu-nm', '-S', str(elf)], text=True)
    entries = [line.split() for line in symbols.splitlines()]
    symbol = next(p for p in entries if len(p) == 4 and p[3] == 'func_80000F48')
    address, size = int(symbol[0], 16), int(symbol[1], 16)
    if address != 0x80000F48:
        raise ValueError(f'Candidate moved: {address:#x}')
    offset = address - 0x80000450
    actual = binary.read_bytes()[offset:offset + size]
    expected = target[0x1B48:0x1DAC]
    differences = [{'vram': hex(address + i), 'expected': expected[i:i + 4].hex(),
                    'actual': actual[i:i + 4].hex()}
                   for i in range(0, max(len(actual), len(expected)), 4)
                   if actual[i:i + 4] != expected[i:i + 4]]
    report = {'function': 'func_80000F48', 'expected_size': len(expected),
              'actual_size': len(actual), 'matches': actual == expected,
              'different_word_count': len(differences), 'different_words': differences,
              'counted_as_matching_c': False}
    (directory / 'report.json').write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps({key: value for key, value in report.items()
                      if key != 'different_words'}, indent=2))


if __name__ == '__main__':
    run()
