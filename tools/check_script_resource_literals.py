"""Freshly compare and execute complete script/resource literal arrays."""
import hashlib
import itertools
import json
from pathlib import Path
from compare_data import compare_unit
from compare_runtime import MATCHING_BLOCKS
from compare_startup import SymbolLayoutSnapshot, compare_block
from owned_sections import elf_sections_and_symbols, source_sections
from rom import ROOT, validate
from resource_literal_execution import run_consumers, run_animation

UNITS = (("src/game/script_service/command_literals.c", 0x80090690, 0x91290, 56),
         ("src/game/actor_resources/animation_literals.c", 0x800906D0, 0x912D0, 52),
         ("src/game/actor_resources/literals.c", 0x80090704, 0x91304, 164))
SUPPORT = ('script_service_commands', 'actor_resource_load', 'script_animation_resolve',
           'game_memory', 'game_string_append', 'string_resource')

def prepare():
    target = (ROOT / 'baseroms/us/baserom.z64').read_bytes()
    validate(target)
    layout = SymbolLayoutSnapshot()
    original, arrays, data_reports = [], [], {}
    for source, address, offset, size in UNITS:
        records = source_sections(source)
        assert len(records) == 1 and (records[0]['vram'], records[0]['rom'], records[0]['size']) == (address, offset, size)
        report = compare_unit(source, records, target, layout)
        assert report['matches']
        path = ROOT / 'build/data-comparison' / Path(source).with_suffix('') / 'compiled.elf'
        sections, _ = elf_sections_and_symbols(path)
        data = sections[records[0]['section']]['bytes']
        assert data == target[offset:offset + size] and len(data) == size
        original.append((address, target[offset:offset + size]))
        arrays.append((address, data))
        data_reports[source] = report
    retail_code, compiled_code, comparisons = [], [], {}
    for name in SUPPORT:
        _, source, start, end = next(x for x in MATCHING_BLOCKS if x[0] == name)
        report = compare_block(name, source, start, start - 0x7FFFF400, end - 0x7FFFF400,
                               target, family='script-resource-literals', layout=layout)
        assert report['matches']
        code = (ROOT / 'build/script-resource-literals' / name / (name + '.bin')).read_bytes()
        retail_code.append((start, target[start - 0x7FFFF400:end - 0x7FFFF400]))
        compiled_code.append((start, code))
        comparisons[name] = report
    layout.verify()
    return original, arrays, retail_code, compiled_code, comparisons, data_reports

def consumer_cases():
    for count, name, level in itertools.product((0, 1, 79, 80), (0, 1, -1, 2147483647), (-7, 0, 219)):
        yield ('scene', count, name, level)
    for count, name in itertools.product((0, 1, 219, 220, 221), (0, 1, -1, 2147483647)):
        yield ('level', count, name, 0)
    for filename in (b'', b'level.scr', b'SCENES\\level.SCR'):
        yield ('setup', filename)
    for model, bitmap, texture, geometry, reply in itertools.product(
            (b'robot', b'robot.GFX', b'robot.v1.gfx'),
            (None, b'robot', b'robot.bmp', b'robot.v1.bmp'),
            (b'robot', b'robot.txr', b'robot.v1.txr'), (0, 1), (-1, 0, 7, 32768, 65535)):
        yield ('resource', model, bitmap, texture, geometry, reply, True, False, 3)
    for defined, loaded, reserve in ((False, False, 3), (True, False, -1), (False, True, 3), (True, True, -1)):
        yield ('resource', b'robot', None, b'robot', 1, 7, defined, loaded, reserve)

def animation_cases():
    for identifier, reference in itertools.product((-3, -2, -1), (0, 1, -1, 65537, 0x7FFFFFFF)):
        yield identifier, b'idle', 0, reference, 17, -7
    for name, result, kind, initial in itertools.product((b'idle', b'walk.KIN', b'foo.bar.baz'),
                                                        (-1, 0, 12, 32768, 65535), (0, 255), (-7, 0, 32767)):
        yield 0, name, result, 65537, kind, initial

def consumer_controls(original, arrays, retail, compiled):
    cases = {0x80090690: ('scene', 80, 0, 0), 0x800906A0: ('level', 220, 0, 0),
             0x800906BC: ('setup', b'level.scr')}
    for offset in (0, 48, 72, 80, 92, 100, 108, 120, 128, 136):
        name = b'robot.bmp' if offset in (92, 120) else b'robot'
        cases[0x80090704 + offset] = ('resource', b'robot', name, name, 1,
                                     -1 if offset == 136 else 7, offset != 0, False, -1 if offset == 48 else 3)
    controls = []
    for address, case in cases.items():
        assert run_consumers(retail, original, case) == run_consumers(compiled, arrays, case)
        bad = []
        for base, data in arrays:
            blob = bytearray(data)
            if base <= address < base + len(data):
                blob[address - base] ^= 1
            bad.append((base, bytes(blob)))
        try:
            run_consumers(compiled, bad, case)
        except AssertionError as error:
            controls.append({'symbol': 'D_' + format(address, 'X'), 'positive_passed': True,
                             'rejected': True, 'reason': str(error)})
        else:
            raise AssertionError(('Literal data corruption escaped', hex(address)))
    return controls

def animation_controls(original, arrays, retail, compiled):
    controls = []
    for offset, case in ((0, (0, b'idle', 0, 1, 17, 0)), (8, (0, b'walk.KIN', 0, 1, 17, 0)),
                         (16, (0, b'idle', 0, 1, 17, 0)), (24, (0, b'idle', -1, 1, 17, 0))):
        assert run_animation(retail, original, case) == run_animation(compiled, arrays, case)
        bad = bytearray(arrays)
        bad[offset] ^= 1
        try:
            run_animation(compiled, bytes(bad), case)
        except AssertionError as error:
            controls.append({'symbol': 'D_' + format(0x800906D0 + offset, 'X'),
                             'positive_passed': True, 'rejected': True, 'reason': str(error)})
        else:
            raise AssertionError('Animation literal data corruption escaped')
    return controls

def formatters(original, arrays):
    from check_scripted_file_diagnostics import prepare as prepare_formatters
    from check_error_formatters import run
    _, _, retail, compiled, support, comparisons, _ = prepare_formatters()
    cases = ((0, 0x80090690, ()), (0, 0x800906A0, ()), (1, 0x800906E8, (b'KINS\\stage.KIN',)),
             (2, 0x80090704, ()), (2, 0x80090734, ()), (2, 0x8009078C, (b'TEXTURES\\stage.TXR',)))
    rows = []
    for index, address, values in cases:
        base, data = original[index]
        text = data[address - base:].split(b'\0', 1)[0]
        case = text, values
        expected = run(retail['error_fatal_format'], support, 0x8001C0D0, 500, case, (address, base, data))
        actual = run(compiled['error_fatal_format'], support, 0x8001C0D0, 500, case, (address, base, arrays[index][1]))
        assert expected == actual
        rows.append({'address': hex(address), 'trace': actual})
    base, data = arrays[2]
    bad = bytearray(data)
    end = bad.find(0, 0x8009078C - base)
    bad[end:] = b'A' * (len(bad) - end)
    try:
        run(compiled['error_fatal_format'], support, 0x8001C0D0, 500,
            (b'Load Texture Map %s failed\n', (b'TEXTURES\\stage.TXR',)), (0x8009078C, base, bytes(bad)))
    except AssertionError as error:
        reason = str(error)
        assert 'read' in reason.lower() and 'bound' in reason.lower(), reason
    else:
        raise AssertionError('Actual guest read outside literal range escaped')
    return rows, {'positive_passed': True, 'rejected': True, 'kind': 'actual_guest_read_bounds', 'reason': reason}, comparisons

def main():
    original, arrays, retail, compiled, comparisons, data = prepare()
    consumers, animations = [], []
    for case in consumer_cases():
        expected = run_consumers(retail, original, case)
        actual = run_consumers(compiled, arrays, case)
        assert expected == actual
        consumers.append(actual)
    for case in animation_cases():
        expected = run_animation(retail, original[1][1], case)
        actual = run_animation(compiled, arrays[1][1], case)
        assert expected == actual
        animations.append(actual)
    controls = consumer_controls(original, arrays, retail, compiled)
    controls += animation_controls(original[1][1], arrays[1][1], retail, compiled)
    formatted, bounds, formatter_comparisons = formatters(original, arrays)
    assert (len(consumers), len(animations), len(formatted), len(controls)) == (435, 105, 6, 17)
    report = {'matches': True, 'consumer_pairs': 435, 'animation_pairs': 105, 'formatter_pairs': 6,
              'principal_executions': 1092, 'complete_array_bytes': 272,
              'real_c_units': len(comparisons), 'real_c_instruction_bytes': sum(len(b) for a, b in compiled),
              'data_comparisons': data, 'comparisons': comparisons, 'formatter_comparisons': formatter_comparisons,
              'data_controls': controls, 'guest_bounds_control': bounds,
              'consumer_results': consumers, 'animation_results': animations, 'formatter_results': formatted,
              'checker_sha256': hashlib.sha256(Path(__file__).read_bytes()).hexdigest(),
              'runner_sha256': hashlib.sha256((ROOT / 'tools/resource_literal_execution.py').read_bytes()).hexdigest(),
              'limitations': ['Fatal capacity/undefined/reserve/texture errors stop at the checked fatal call; their continuation is unverified.',
                              'The animation failure diagnostic returns synthetically through its checked ABI boundary to exercise the resolver epilogue.',
                              'Returning file-loader, reservation, string-table and script-parser services use checked ABI boundaries that clobber caller-saved integer and FPU registers.',
                              'Integer preserved registers, GP/SP/RA on returning consumers, twelve distinct saved FPU words, complete object/data guards and all guest instruction/read/write bounds are checked.',
                              'Resource-loader fixtures have ten null animation pointers; the animation resolver executes separately.',
                              'The actual formatter and string/numeric helpers execute; output/fatal reporting uses its documented ABI boundaries.',
                              'The eight-byte command/animation gap is unreadable/unowned. Bounded indices/paths below100 bytes only; file I/O, script interpretation, arbitrary aliasing and gameplay remain unverified.']}
    path = ROOT / 'build/script-resource-literals/report.json'
    path.write_text(json.dumps(report, indent=2) + '\n')
    print('Passed 546 literal pairs/1092 executions; all 272 bytes; 17 data controls and actual guest read bounds control', flush=True)

if __name__ == '__main__':
    main()
