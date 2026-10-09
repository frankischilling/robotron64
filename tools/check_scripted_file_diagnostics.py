"""Execute complete scripted-file diagnostic arrays with matched formatters."""

import hashlib
import json
from pathlib import Path

from check_error_formatters import SUPPORT, run
from compare_data import compare_unit
from compare_runtime import MATCHING_BLOCKS
from compare_startup import SymbolLayoutSnapshot, compare_block
from owned_sections import elf_sections_and_symbols, source_sections
from rom import ROOT, validate


SOURCE = 'src/game/script_service/diagnostics.c'
BASE, SIZE = 0x800904B0, 480
FORMATS = ((0x800904B0, 32, 'unique'), (0x800904D0, 64, 'register'),
           (0x80090510, 60, 'find'), (0x8009054C, 56, 'find_failed'),
           (0x80090584, 52, 'load'), (0x800905B8, 64, 'get'),
           (0x800905F8, 56, 'get_failed'), (0x80090630, 48, 'release'),
           (0x80090660, 48, 'unregister'))


def prepare():
    target = (ROOT / 'baseroms/us/baserom.z64').read_bytes()
    validate(target)
    layout = SymbolLayoutSnapshot()
    records = source_sections(SOURCE)
    assert len(records) == 1
    assert (records[0]['vram'], records[0]['rom'], records[0]['size']) == (BASE, 0x910B0, SIZE)
    data_report = compare_unit(SOURCE, records, target, layout)
    assert data_report['matches']
    sections, _ = elf_sections_and_symbols(ROOT / 'build/data-comparison' / Path(SOURCE).with_suffix('') / 'compiled.elf')
    arrays = sections['.scripted_file_diagnostics']['bytes']
    original = target[0x910B0:0x91290]
    assert arrays == original and len(arrays) == SIZE
    comparisons, retail, compiled, support = {}, {}, {}, []
    for name in ('error_fatal_format', 'error_formatted') + SUPPORT:
        _, source, start, end = next(record for record in MATCHING_BLOCKS if record[0] == name)
        report = compare_block(name, source, start, start - 0x7FFFF400,
                               end - 0x7FFFF400, target, family='scripted-file-diagnostics', layout=layout)
        assert report['matches'], name
        comparisons[name] = report
        directory = ROOT / 'build/scripted-file-diagnostics' / name
        code = (directory / (name + '.bin')).read_bytes()
        sections, _ = elf_sections_and_symbols(directory / (name + '.elf'))
        if name in ('error_fatal_format', 'error_formatted'):
            retail[name] = [(start, target[start - 0x7FFFF400:end - 0x7FFFF400])]
            compiled[name] = [(start, code)]
            for owned in source_sections(source):
                assert owned['rom'] is not None
                compiled[name].append((owned['vram'], sections[owned['section']]['bytes']))
                retail[name].append((owned['vram'], target[owned['rom']:owned['rom'] + owned['size']]))
        else:
            support.append((start, code))
            for owned in source_sections(source):
                if owned['rom'] is not None:
                    support.append((owned['vram'], sections[owned['section']]['bytes']))
    for source in ('src/game/diagnostics/messages.c', 'src/game/formatting/digits.c'):
        owned = source_sections(source)
        report = compare_unit(source, owned, target, layout)
        assert report['matches']
        sections, _ = elf_sections_and_symbols(ROOT / 'build/data-comparison' / Path(source).with_suffix('') / 'compiled.elf')
        support += [(item['vram'], sections[item['section']]['bytes']) for item in owned]
    layout.verify()
    return original, arrays, retail, compiled, support, comparisons, data_report


def cases(original):
    for address, size, kind in FORMATS:
        offset = address - BASE
        field = original[offset:offset + size]
        text = field.split(b'\0', 1)[0]
        assert len(field) == size and field[len(text):] == bytes(size - len(text))
        for handle, name in ((0, b'NEW.DAT'), (17, b'FiLe17'), (99, b'last.dat')):
            pointer = 0x80218010 + handle * 4
            values = {'unique': (), 'register': (handle, name), 'find': (handle, name),
                      'find_failed': (name,), 'load': (handle, pointer), 'get': (pointer, handle),
                      'get_failed': (handle,), 'release': (handle,), 'unregister': (handle,)}[kind]
            formatter = 'error_fatal_format' if kind in ('unique', 'find_failed', 'get_failed') else 'error_formatted'
            yield address, formatter, (text, values)


def execute(original, arrays, retail, compiled, support):
    traces = []
    for address, name, case in cases(original):
        _, _, start, end = next(row for row in MATCHING_BLOCKS if row[0] == name)
        expected = run(retail[name], support, start, end - start, case, (address, BASE, original))
        actual = run(compiled[name], support, start, end - start, case, (address, BASE, arrays))
        assert actual == expected
        traces.append({'address': hex(address), 'formatter': name, 'trace': actual})
    return traces


def main():
    original, arrays, retail, compiled, support, comparisons, data_report = prepare()
    traces = execute(original, arrays, retail, compiled, support)
    assert len(traces) == 27 and len({row['address'] for row in traces}) == 9
    report = {'matches': True, 'paired_cases': len(traces), 'target_executions': 2 * len(traces),
              'complete_array_bytes': SIZE, 'data_sha256': hashlib.sha256(arrays).hexdigest(),
              'data_comparison': data_report, 'comparisons': comparisons, 'traces': traces,
              'checker_sha256': hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
              'limitations': ['Output and fatal reporter use recorded ABI-clobbering boundaries; the fatal reporter returns synthetically.',
                              'Actual complete formatter, dispatch table, hexadecimal alphabet and numeric/string helper code execute.',
                              'All instruction/read/write bounds, complete immutable arrays, stack guards, integer and FPU preservation are checked.',
                              'Unsupported percent-l conversions retain retail argument consumption and output.',
                              'File I/O, script interpretation, overflowing strings and gameplay are outside this audit.']}
    path = ROOT / 'build/scripted-file-diagnostics/report.json'
    path.write_text(json.dumps(report, indent=2) + '\n')
    print('Passed 27 paired diagnostics,54 executions;all480 bytes and nine real-address arrays',flush=True)


if __name__ == '__main__':
    main()
