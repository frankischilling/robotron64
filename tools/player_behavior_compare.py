"""Compare complete player behavior code and both generated dispatch tables.

The source is excluded from ROM ownership. A successful audit is separate
from exact matching of the complete code and all 16 dispatch addresses.
"""
from pathlib import Path
import hashlib, json, struct, subprocess
from elftools.elf.elffile import ELFFile
from rom import ROOT, validate
from compiler import compile_source, profile_for_source
from compare_startup import external_assignments, comparison_input_hashes
from owned_sections import elf_sections_and_symbols
from trim_padding import trim
from toolchain import installed_identity

ENTRY, END, TABLE, TABLE_END = 0x80033974, 0x80035190, 0x80094254, 0x80094294
SOURCE = 'src/game/player/behavior.c'

def compare_candidate_block(name, source, target, layout, family='runtime-candidates'):
    validate(target)
    layout.verify()
    assert source == SOURCE or (source.startswith('build/player-behavior-audit/') and source.endswith('.c'))
    inputs = comparison_input_hashes(source)
    inputs['tools/player_behavior_compare.py'] = hashlib.sha256(Path(__file__).read_bytes()).hexdigest()
    out = ROOT / 'build' / family / name
    out.mkdir(parents=True, exist_ok=True)
    raw, obj, elf = [out / (name + suffix) for suffix in ('.raw.o', '.o', '.elf')]
    compile_source(source, raw)
    sections, symbols = elf_sections_and_symbols(raw)
    function = symbols['func_80033974']
    assert function['type'] == 2 and function['section'] == '.text' and function['value'] == 0
    assert not any(value['type'] == 2 and value['index'] != 0 and key != 'func_80033974' for key, value in symbols.items())
    natural = function['size']
    assert natural > 0 and natural % 4 == 0
    assert not any(sections['.text']['bytes'][natural:]), 'Live code after function'
    assert sections['.rodata']['size'] == 64, 'Complete dispatch tables required'
    for key, value in sections.items():
        assert not value['size'] or not value['flags'] & 2 or key in ('.text', '.rodata', '.reginfo', '.MIPS.abiflags'), ('Unexpected allocation', key)
    with raw.open('rb') as fp:
        image = ELFFile(fp)
        rel = image.get_section_by_name('.rel.rodata')
        assert rel is not None and rel.num_relocations() == 16
        symtab = image.get_section(rel['sh_link'])
        text_index = next(i for i, section in enumerate(image.iter_sections()) if section.name == '.text')
        for i, item in enumerate(rel.iter_relocations()):
            assert item['r_info_type'] == 2 and item['r_offset'] == i * 4
            assert symtab.get_symbol(item['r_info_sym'])['st_shndx'] == text_index
    # Remove only independently checked assembler zeros, never live code.
    obj.write_bytes(trim(raw.read_bytes(), '.text', natural))
    undefined = {line.split()[-1] for line in subprocess.check_output(['mips-linux-gnu-nm', '-u', str(obj)], text=True).splitlines() if line.strip()}
    ld = out / (name + '.ld')
    ld.write_text(external_assignments(undefined, layout.addresses) +
        'SECTIONS { .text 0x80033974 : SUBALIGN(4) { *(.text) } .rodata 0x80094254 : SUBALIGN(4) { *(.rodata) } /DISCARD/ : { *(.reginfo .MIPS.abiflags) } }\n')
    subprocess.run(['mips-linux-gnu-ld', '-EB', '-T', str(ld), '-e', 'func_80033974', '-o', str(elf), str(obj)], check=True)
    linked, linked_symbols = elf_sections_and_symbols(elf)
    code, tables = linked['.text']['bytes'], linked['.rodata']['bytes']
    assert linked_symbols['func_80033974']['value'] == ENTRY
    assert len(code) == natural and len(tables) == 64
    assert not linked['.rodata']['flags'] & 1
    assert all(ENTRY <= address < ENTRY + natural and address % 4 == 0 for address in struct.unpack('>16I', tables))
    assert code[:2] == b'\x27\xbd'
    original, original_tables = target[0x34574:0x35D90], target[0x94E54:0x94E94]
    report = dict(source=source, inputs_sha256=inputs, compiler_profile=profile_for_source(source),
        toolchain_identity=installed_identity('5.3'), natural_function_size=natural,
        actual_size=natural, expected_size=6172, frame=-int.from_bytes(code[2:4], 'big', signed=True),
        retail_frame=184, matches=code == original and tables == original_tables,
        different_words=[dict(vram=hex(ENTRY+i), expected=original[i:i+4].hex(), actual=code[i:i+4].hex())
            for i in range(0, max(len(code), len(original)), 4) if code[i:i+4] != original[i:i+4]],
        dispatch=dict(bytes=64, matches=tables == original_tables,
            differing_words=[i for i in range(0, 64, 4) if tables[i:i+4] != original_tables[i:i+4]]),
        elf=elf.relative_to(ROOT).as_posix(), code_sha256=hashlib.sha256(code).hexdigest(),
        tables_sha256=hashlib.sha256(tables).hexdigest(), source_ownership_added=0)
    for filename, digest in inputs.items():
        assert hashlib.sha256((ROOT / filename).read_bytes()).hexdigest() == digest
    layout.verify()
    (out / (name + '.json')).write_text(json.dumps(report, indent=2) + '\n')
    return report

def verify_helpers(target, layout, family='player-behavior-audit/helpers'):
    """Freshly compile and compare the four complete helpers executed by the audit."""
    records = json.loads((ROOT / 'config/functions.json').read_text())
    out = ROOT / 'build' / family
    out.mkdir(parents=True, exist_ok=True)
    verified = []
    for name in ('func_800338CC', 'func_8004CEF0', 'func_8003B520', 'func_80036064'):
        record = next(row for row in records if row['name'] == name)
        inputs = comparison_input_hashes(record['source'])
        raw = out / (name + '.raw.o')
        compile_source(record['source'], raw)
        sections, symbols = elf_sections_and_symbols(raw)
        assert symbols[name]['size'] == record['size']
        undefined = {line.split()[-1] for line in subprocess.check_output(['mips-linux-gnu-nm', '-u', str(raw)], text=True).splitlines() if line.strip()}
        ld = out / (name + '.ld')
        ld.write_text(external_assignments(undefined, layout.addresses) +
            'SECTIONS { .text 0x%X : SUBALIGN(4) { *(.text) } /DISCARD/ : { *(.reginfo .MIPS.abiflags) } }\n' % record['section_vram'])
        elf = out / (name + '.elf')
        subprocess.run(['mips-linux-gnu-ld', '-T', str(ld), '-e', name, '-o', str(elf), str(raw)], check=True)
        linked, linked_symbols = elf_sections_and_symbols(elf)
        entry = linked_symbols[name]['value']
        offset = entry - linked['.text']['address']
        code = linked['.text']['bytes'][offset:offset+record['size']]
        assert entry == record['vram'] and code == target[record['rom']:record['rom']+record['size']], name
        for filename, digest in inputs.items():
            assert hashlib.sha256((ROOT / filename).read_bytes()).hexdigest() == digest
        verified.append(dict(name=name, start=entry, end=entry+len(code), source=record['source'],
            instruction_bytes=len(code), code_sha256=hashlib.sha256(code).hexdigest(),
            inputs_sha256=inputs, compiler_profile=profile_for_source(record['source'])))
    layout.verify()
    (out / 'receipt.json').write_text(json.dumps(verified, indent=2) + '\n')
    return verified
