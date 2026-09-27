"""Compare the excluded text replacement candidate with the validated ROM.

Compile the candidate independently with the shared recovered types and
prototypes, without adding it to the production build or progress count.
"""

import argparse
import hashlib
import json
from pathlib import Path
import subprocess
from rom import ROOT, validate
from toolchain import install


def run(compiler="5.3", optimization="O2", isa="1", source_path=None):
    target = (ROOT / 'baseroms/us/baserom.z64').read_bytes()
    validate(target)
    install(compiler)
    directory = ROOT / 'build/text-replacement-comparison'
    directory.mkdir(parents=True, exist_ok=True)
    source = directory / 'candidate.c'
    source.write_text((source_path or ROOT / 'src/game/text_replacement.c').read_text())
    obj = directory / 'candidate.o'
    subprocess.run([str(ROOT / '.local/toolchain' / compiler / 'cc'), '-c', '-' + optimization, '-G', '0',
                    '-non_shared', '-mips' + isa, '-32', '-o', str(obj), str(source)],
                   check=True, cwd=ROOT)
    script = directory / 'candidate.ld'
    definitions = (ROOT / 'linker_scripts/us.ld').read_text().split('SECTIONS')[0]
    for function in json.loads((ROOT / 'config/functions.json').read_text()):
        if function['name'] != '_start':
            definitions += f"{function['name']} = {function['vram']:#x};\n"
    script.write_text(definitions + '''SECTIONS {
.text_start 0x80000F48 : SUBALIGN(4) { *(.text) }
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
    offset = address - 0x80000F48
    actual = binary.read_bytes()[offset:offset + size]
    expected = target[0x1B48:0x1DAC]
    differences = [{'vram': hex(address + i), 'expected': expected[i:i + 4].hex(),
                    'actual': actual[i:i + 4].hex()}
                   for i in range(0, max(len(actual), len(expected)), 4)
                   if actual[i:i + 4] != expected[i:i + 4]]
    report = {'compiler': compiler, 'optimization': optimization, 'isa': isa,
              'source_sha256': hashlib.sha256(source.read_bytes()).hexdigest(),
              'types_sha256': hashlib.sha256((ROOT / 'include/text.h').read_bytes()).hexdigest(),
              'function': 'func_80000F48', 'expected_size': len(expected),
              'actual_size': len(actual), 'matches': actual == expected,
              'different_word_count': len(differences), 'different_words': differences,
              'counted_as_matching_c': False}
    (directory / 'report.json').write_text(json.dumps(report, indent=2) + '\n')
    print(json.dumps({key: value for key, value in report.items()
                      if key != 'different_words'}, indent=2))


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--compiler', choices=['5.3', '7.1'], default='5.3')
    parser.add_argument('--optimization', choices=['O1', 'O2'], default='O2')
    parser.add_argument('--isa', choices=['1', '2'], default='1')
    parser.add_argument('--source', type=Path, help='Alternate research candidate')
    args = parser.parse_args()
    run(args.compiler, args.optimization, args.isa, args.source)
