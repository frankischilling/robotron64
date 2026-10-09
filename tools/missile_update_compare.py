"""Compare the whole excluded missile callback and its seven relocatable entries."""
from pathlib import Path
import hashlib
import json
import struct
import subprocess
from elftools.elf.elffile import ELFFile
from compiler import compile_source, profile_for_source
from compare_startup import external_assignments, comparison_input_hashes
from owned_sections import elf_sections_and_symbols
from trim_padding import trim
from toolchain import installed_identity
from rom import ROOT, validate

ENTRY, SIZE, TABLE, TABLE_SIZE = 0x80038830, 1372, 0x80094BF0, 28

def compare_candidate_block(name, source, target, layout, family='runtime-candidates'):
    validate(target)
    layout.verify()
    source = ROOT / source
    inputs = comparison_input_hashes(source.relative_to(ROOT).as_posix())
    inputs['tools/missile_update_compare.py'] = hashlib.sha256(Path(__file__).read_bytes()).hexdigest()
    out = ROOT / 'build' / family / name
    out.mkdir(parents=True, exist_ok=True)
    r = ROOT
    rom = target
    raw, obj, elf_path = (out / (name + suffix) for suffix in ('.raw.o', '.o', '.elf'))
    compile_source(source.relative_to(r).as_posix(), raw)
    sections, symbols = elf_sections_and_symbols(raw)
    function = symbols['func_80038830']
    raw_text_bytes = sections['.text']['size']
    assert function['type'] == 2 and function['section'] == '.text' and function['value'] == 0
    assert not any(value['type'] == 2 and value.get('index') != 0 and key != 'func_80038830'
                   for key, value in symbols.items()), 'Additional procedure'
    with raw.open('rb') as fp:
        elf = ELFFile(fp)
        rel = elf.get_section_by_name('.rel.rodata')
        assert rel is not None and rel.num_relocations() == 7
        assert all(item['r_info_type'] == 2 and item['r_offset'] == i * 4 for i, item in enumerate(rel.iter_relocations()))
        symtab = elf.get_section(rel['sh_link'])
        text_index = next(i for i, section in enumerate(elf.iter_sections()) if section.name == '.text')
        assert all(symtab.get_symbol(item['r_info_sym'])['st_shndx'] == text_index for item in rel.iter_relocations())
    for key, value in sections.items():
        assert not value['size'] or not value['flags'] & 2 or key in ('.text', '.rodata', '.reginfo', '.MIPS.abiflags'), ('Unexpected allocation', key)
    obj.write_bytes(trim(trim(raw.read_bytes(), '.text', function['size']), '.rodata', TABLE_SIZE))
    undefined = {line.split()[-1] for line in subprocess.check_output(['mips-linux-gnu-nm', '-u', str(obj)], text=True).splitlines()}
    ld = out / (name + '.ld')
    ld.write_text(external_assignments(undefined, layout.addresses) +
        f'SECTIONS {{ .text 0x{ENTRY:X} : SUBALIGN(4) {{ *(.text) }} .rodata 0x{TABLE:X} : SUBALIGN(4) {{ *(.rodata) }} /DISCARD/ : {{ *(.reginfo .MIPS.abiflags) }} }}\n')
    subprocess.run(['mips-linux-gnu-ld', '-EB', '-T', str(ld), '-e', 'func_80038830', '-o', str(elf_path), str(obj)], check=True)
    sections, linked = elf_sections_and_symbols(elf_path)
    actual, table = sections['.text']['bytes'], sections['.rodata']['bytes']
    assert len(actual) == function['size'] and len(table) == TABLE_SIZE
    assert all(ENTRY <= address < ENTRY + len(actual) and address % 4 == 0 for address in struct.unpack('>7I', table))
    assert not sections['.rodata']['flags'] & 1
    expected, expected_table = rom[0x39430:0x3998C], rom[0x957F0:0x9580C]
    report = dict(source=source.relative_to(r).as_posix(), inputs_sha256=inputs,
        compiler_profile=profile_for_source(source.relative_to(r).as_posix()), toolchain_identity=installed_identity('5.3'),
        natural_bytes=function['size'], raw_text_bytes=raw_text_bytes,
        frame=-int.from_bytes(actual[2:4], 'big', signed=True), matches=actual == expected and table == expected_table,
        different_words=[dict(vram=hex(ENTRY + i), expected=expected[i:i+4].hex(), actual=actual[i:i+4].hex())
                         for i in range(0, max(len(actual), len(expected)), 4) if expected[i:i+4] != actual[i:i+4]],
        dispatch=dict(matches=table == expected_table, bytes=TABLE_SIZE,
                      differing_words=[i for i in range(0, TABLE_SIZE, 4) if table[i:i+4] != expected_table[i:i+4]]),
        source_sha256=hashlib.sha256(source.read_bytes()).hexdigest(), source_ownership_added=0, expected_size=SIZE, actual_size=len(actual), natural_function_size=function['size'])
    (out / (name + '.bin')).write_bytes(actual)
    (out / (name + '-dispatch.bin')).write_bytes(table)
    for filename, digest in report['inputs_sha256'].items():
        assert hashlib.sha256((ROOT / filename).read_bytes()).hexdigest() == digest
    layout.verify()
    (out / (name + '.json')).write_text(json.dumps(report, indent=2) + '\n')
    return report
