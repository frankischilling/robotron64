"""Check complete setup/table comparisons with synthetic, noncommercial objects."""
from contextlib import redirect_stdout
import io
from pathlib import Path
import shutil
import struct
import subprocess
import sys
import tempfile
import unittest
from unittest.mock import Mock, patch

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / 'tools'))

import check_scene_resource_setup as setup
from compare_runtime import compare_blocks
from compare_startup import compare_block


class SetupRoutingTests(unittest.TestCase):
    def test_runtime_keeps_the_compound_table_result_and_output_family(self):
        result = {'matches': False, 'actual_size': 2660, 'expected_size': 2660,
                  'different_words': [], 'dispatch': {'matches': False}}
        target, layout = b'synthetic', object()
        record = ('scene_resource_setup', setup.SOURCE, setup.ENTRY, setup.ENTRY + 2660)
        with patch.object(setup, 'compare_candidate_block', return_value=result) as compare, \
                redirect_stdout(io.StringIO()):
            blocks = compare_blocks([record], target, 'separate-probe', layout)
        compare.assert_called_once_with('scene_resource_setup', setup.SOURCE,
                                        target, layout, 'separate-probe')
        self.assertIs(blocks['scene_resource_setup'], result)
        self.assertFalse(blocks['scene_resource_setup']['matches'])

    def test_workbench_uses_the_complete_compound_comparison(self):
        result, target, layout = {'matches': False}, b'synthetic', object()
        with patch.object(setup, 'compare_candidate_block', return_value=result) as compare:
            actual = compare_block('probe', setup.SOURCE, setup.ENTRY,
                                   0x1DFF0, 0x1EA54, target, 'workbench', layout)
        self.assertIs(actual, result)
        compare.assert_called_once_with('probe', setup.SOURCE, target, layout, 'workbench')

    def test_workbench_rejects_prefixes_and_displaced_code_before_compilation(self):
        for address, start, end in [(setup.ENTRY, 0x1DFF0, 0x1EA50),
                                    (setup.ENTRY, 0x1DFF4, 0x1EA54),
                                    (setup.ENTRY + 4, 0x1DFF0, 0x1EA54)]:
            with self.subTest(address=address, start=start, end=end), \
                    patch.object(setup, 'compare_candidate_block') as compare:
                with self.assertRaisesRegex(ValueError, 'complete retail range'):
                    compare_block('probe', setup.SOURCE, address, start, end, b'')
                compare.assert_not_called()


@unittest.skipUnless(all(shutil.which(name) for name in
                        ('mips-linux-gnu-as', 'mips-linux-gnu-ld', 'mips-linux-gnu-nm')),
                     'MIPS binutils are required')
class SetupObjectTests(unittest.TestCase):
    def setUp(self):
        directory = tempfile.TemporaryDirectory()
        self.addCleanup(directory.cleanup)
        self.root = Path(directory.name)
        self.layout = Mock(addresses={})

    def assemble(self, entries=10, extra_code='', extra_procedure=''):
        source = self.root / 'synthetic.s'
        source.write_text('.set noreorder\n.text\n.globl func_8001D3F0\n'
                          '.type func_8001D3F0,@function\nfunc_8001D3F0:\n'
                          '.rept 663\nnop\n.endr\njr $ra\nnop\n' + extra_code +
                          '.size func_8001D3F0,.-func_8001D3F0\n' + extra_procedure +
                          '.section .rodata\n.rept ' + str(entries) +
                          '\n.word func_8001D3F0\n.endr\n')
        obj = self.root / 'synthetic.o'
        subprocess.run(['mips-linux-gnu-as', '-EB', '-32', '-march=vr4300',
                        '-o', str(obj), str(source)], check=True, capture_output=True)
        return obj

    def compare(self, obj, change_table=False):
        target = bytearray(0x800000)
        code = bytes(663 * 4) + struct.pack('>II', 0x03E00008, 0)
        target[setup.CODE_ROM:setup.CODE_ROM + 2660] = code
        table = [setup.ENTRY] * 10
        if change_table:
            table[-1] += 4
        target[setup.DISPATCH_ROM:setup.DISPATCH_ROM + 40] = struct.pack('>10I', *table)
        def compile_fixture(source, output):
            shutil.copyfile(obj, output)
        with patch.object(setup, 'ROOT', self.root), \
                patch.object(setup, 'validate'), \
                patch.object(setup, 'compile_source', side_effect=compile_fixture), \
                patch.object(setup, 'comparison_input_hashes', return_value={}), \
                patch.object(setup, 'profile_for_source', return_value={'version': 'synthetic'}), \
                patch.object(setup, 'installed_identity', return_value={}), \
                patch.object(setup, 'external_assignments', return_value=''):
            return setup.compare_candidate_block('probe', 'synthetic.c', bytes(target), self.layout)

    def test_code_and_all_ten_linked_entries_are_compared_without_ownership_credit(self):
        result = self.compare(self.assemble())
        self.assertTrue(result['matches'])
        self.assertEqual(result['actual_size'], 2660)
        self.assertEqual(result['dispatch']['actual_size'], 40)
        self.assertEqual(result['dispatch']['vram'], '0x800907c8')
        self.assertEqual(len(result['dispatch']['relocations']), 10)
        self.assertFalse(result['matching_source_claim'])
        self.assertFalse(result['retained_literal']['source_owned'])

    def test_last_table_word_mismatch_fails_even_when_every_code_byte_matches(self):
        result = self.compare(self.assemble(), change_table=True)
        self.assertEqual(result['different_words'], [])
        self.assertFalse(result['matches'])
        self.assertEqual([word['offset'] for word in result['dispatch']['different_words']], [36])

    def test_live_zero_instruction_after_the_target_extent_is_not_trimmed(self):
        result = self.compare(self.assemble(extra_code='nop\n'))
        self.assertEqual(result['natural_function_size'], 2664)
        self.assertEqual(result['actual_size'], 2664)
        self.assertFalse(result['matches'])
        self.assertEqual(result['different_words'][-1]['vram'], hex(setup.ENTRY + 2660))

    def test_incomplete_table_cannot_produce_a_comparison_report(self):
        with self.assertRaisesRegex(ValueError, 'ten complete'):
            self.compare(self.assemble(entries=9))

    def test_additional_procedure_is_rejected(self):
        extra = ('.globl another\n.type another,@function\nanother:\n'
                 'jr $ra\nnop\n.size another,.-another\n')
        with self.assertRaisesRegex(ValueError, 'additional procedure'):
            self.compare(self.assemble(extra_procedure=extra))


if __name__ == '__main__':
    unittest.main()
