"""Reassemble every manifest-owned assembly unit and verify its complete linked text."""

import hashlib
import json
from pathlib import Path
import re
import shutil
import subprocess

from compare_startup import external_assignments, symbol_addresses
from manifest import load_manifest
from owned_sections import elf_sections_and_symbols
from provenance import local_headers, record as record_provenance
from rom import ROOT, validate


ASSEMBLER_FLAGS = ('-EB', '-32', '-march=vr4300')


def verify_procedures(path, records, linked=False):
    """Accept exact aliases without counting them as additional procedures."""
    _, table = elf_sections_and_symbols(path)
    section = records[0]['section'] if linked else '.text'
    base = 0 if linked else records[0]['section_vram']
    extents = set()
    for record in records:
        expected = (record['vram'] - base, record['size'])
        symbol = table.get(record['name'])
        if (not symbol or symbol['type'] != 2 or symbol['section'] != section
                or (symbol['value'], symbol['size']) != expected):
            raise ValueError(f'Assembly procedure extent differs: {record["name"]}')
        extents.add(expected)
    aliases = {}
    names = {record['name'] for record in records}
    for name, symbol in table.items():
        if symbol['type'] != 2 or symbol['section'] != section:
            continue
        if (symbol['value'], symbol['size']) not in extents:
            raise ValueError(f'Unrecorded or partial assembly procedure: {name}')
        if name not in names:
            aliases[name] = {'value': symbol['value'], 'size': symbol['size']}
    return aliases


def verify_text_coverage(text, records):
    """Require all bytes outside declared procedures to be zero alignment."""
    origin = records[0]['section_vram']
    covered = bytearray(len(text))
    for record in records:
        start = record['vram'] - origin
        end = start + record['size']
        if start < 0 or end > len(text):
            raise ValueError(f'Assembly procedure leaves the input text: {record["name"]}')
        if any(covered[start:end]):
            raise ValueError('Overlapping assembly procedures cannot be counted twice')
        covered[start:end] = b'\1' * record['size']
    if any(value for value, owned in zip(text, covered) if not owned):
        raise ValueError('Assembly text has unowned nonzero instruction bytes')
    return len(text) - sum(covered)


def compare_unit(source, records, target, assembler):
    directory = ROOT / 'build/assembly-comparison' / Path(source).stem
    directory.mkdir(parents=True, exist_ok=True)
    inputs = [source, *sorted(local_headers(ROOT / source, ROOT))]
    for filename in inputs:
        destination = directory / 'inputs' / filename
        destination.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(ROOT / filename, destination)
    obj, elf = directory / 'compiled.o', directory / 'compiled.elf'
    subprocess.run([assembler, *ASSEMBLER_FLAGS, '-o', str(obj), source],
                   cwd=ROOT, check=True)
    object_sections, _ = elf_sections_and_symbols(obj)
    allowed = {'.text', '.reginfo', '.MIPS.abiflags'}
    for name, section in object_sections.items():
        if section['flags'] & 2 and section['size'] and name not in allowed:
            raise ValueError(f'Assembly comparison has unrecorded allocated section: {name}')
    aliases = verify_procedures(obj, records)
    text = object_sections['.text']['bytes']
    padding = verify_text_coverage(text, records)
    undefined = {line.split()[-1] for line in subprocess.check_output(
        ['mips-linux-gnu-nm', '-u', str(obj)], text=True).splitlines() if line.strip()}
    known = symbol_addresses()
    for name, value in re.findall(r'^([\w]+)\s*=\s*(0x[0-9a-fA-F]+);',
                                  (ROOT / 'linker_scripts/us.ld').read_text(), re.MULTILINE):
        address = int(value, 16)
        if name in known and known[name] != address:
            raise ValueError(f'Conflicting assembly external address: {name}')
        known[name] = address
    script = external_assignments(undefined, known)
    script += (f'SECTIONS {{ {records[0]["section"]} 0x{records[0]["section_vram"]:X} '
               f': SUBALIGN(4) {{ *(.text) }} }}\n')
    (directory / 'compiled.ld').write_text(script)
    subprocess.run(['mips-linux-gnu-ld', '-EB', '-m', 'elf32btsmip',
                    '-T', str(directory / 'compiled.ld'), '-e', records[0]['name'],
                    '-o', str(elf), str(obj)], check=True)
    verify_procedures(elf, records, linked=True)
    linked_sections, _ = elf_sections_and_symbols(elf)
    output = linked_sections[records[0]['section']]
    actual = output['bytes']
    rom_start = records[0]['rom'] - (records[0]['vram'] - records[0]['section_vram'])
    expected = target[rom_start:rom_start + len(actual)]
    differences = [
        {'vram': hex(records[0]['section_vram'] + offset),
         'actual': actual[offset:offset + 4].hex(),
         'expected': expected[offset:offset + 4].hex()}
        for offset in range(0, max(len(actual), len(expected)), 4)
        if actual[offset:offset + 4] != expected[offset:offset + 4]
    ]
    record_provenance(source, obj.relative_to(ROOT).as_posix(), inputs[1:])
    (directory / 'compiled.bin').write_bytes(actual)
    (directory / 'symbols.txt').write_text(subprocess.check_output(
        ['mips-linux-gnu-readelf', '-Ws', str(elf)], text=True))
    (directory / 'compiled.s').write_text(subprocess.check_output(
        ['mips-linux-gnu-objdump', '-d', str(elf)], text=True))
    result = {
        'source': source, 'assembler_flags': list(ASSEMBLER_FLAGS),
        'source_sha256': hashlib.sha256((ROOT / source).read_bytes()).hexdigest(),
        'inputs_sha256': {name: hashlib.sha256((ROOT / name).read_bytes()).hexdigest()
                          for name in inputs},
        'function_count': len(records), 'live_bytes': sum(record['size'] for record in records),
        'alignment_bytes': padding, 'raw_text_size': len(text),
        'actual_size': len(actual), 'expected_size': len(expected),
        'aliases': aliases, 'different_words': differences,
        'matches': len(actual) == len(text) and actual == expected,
    }
    (directory / 'report.json').write_text(json.dumps(result, indent=2) + '\n')
    return result


def run():
    assembler = shutil.which('mips-linux-gnu-as')
    if not assembler:
        raise SystemExit('mips-linux-gnu-as is required for assembly comparisons')
    target = (ROOT / 'baseroms/us/baserom.z64').read_bytes()
    validate(target)
    groups = {}
    for record in load_manifest():
        if record.get('language', 'C') == 'assembly':
            groups.setdefault(record['source'], []).append(record)
    if not groups:
        raise SystemExit('The function manifest has no assembly sources')
    results = {}
    for source, records in groups.items():
        records.sort(key=lambda record: record['vram'])
        result = compare_unit(source, records, target, assembler)
        results[source] = result
        print(f'{source}: {result["function_count"]} functions, '
              f'{result["live_bytes"]} live bytes, {result["alignment_bytes"]} alignment bytes; '
              f'{len(result["different_words"])} differing words', flush=True)
    report = {
        'assembler': str(Path(assembler).resolve()),
        'assembler_version': subprocess.check_output([assembler, '--version'], text=True).splitlines()[0],
        'assembler_sha256': hashlib.sha256(Path(assembler).read_bytes()).hexdigest(),
        'matches': all(result['matches'] for result in results.values()), 'blocks': results,
    }
    path = ROOT / 'build/assembly-comparison/report.json'
    path.write_text(json.dumps(report, indent=2) + '\n')
    print(f'Report: {path.relative_to(ROOT)}', flush=True)
    if not report['matches']:
        raise SystemExit('Assembly comparison includes nonmatching source; see the report')


if __name__ == '__main__':
    run()
