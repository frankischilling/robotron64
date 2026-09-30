import shutil
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / 'tools'))

from compare_assembly import verify_procedures, verify_text_coverage


def record(name='copy', size=8, address=0x80001000):
    return {'name': name, 'size': size, 'vram': address,
            'section_vram': 0x80001000, 'section': '.copy'}


class AssemblyCoverageTests(unittest.TestCase):
    def test_alignment_is_not_counted_as_function_bytes(self):
        self.assertEqual(verify_text_coverage(b'\x01\x02\x03\x04' * 2 + bytes(24), [record()]), 24)

    def test_unowned_instructions_and_overlapping_alias_counts_fail(self):
        with self.assertRaisesRegex(ValueError, 'unowned nonzero'):
            verify_text_coverage(bytes(8) + b'\x01\x02\x03\x04', [record()])
        with self.assertRaisesRegex(ValueError, 'cannot be counted twice'):
            verify_text_coverage(bytes(16), [record(), record('alias')])


@unittest.skipUnless(shutil.which('mips-linux-gnu-as'), 'MIPS binutils are required')
class AssemblyAliasTests(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory()
        self.addCleanup(self.directory.cleanup)
        self.root = Path(self.directory.name)

    def assemble(self, alias_size=8, extra=''):
        source = self.root / 'copy.s'
        source.write_text(
            '.set noreorder\n.text\n.globl copy\n.type copy,@function\n'
            'copy:\njr $ra\nnop\n.size copy,.-copy\n'
            f'.weak alias\n.type alias,@function\n.set alias,copy\n.size alias,{alias_size}\n'
            + extra)
        obj = self.root / 'copy.o'
        subprocess.run(['mips-linux-gnu-as', '-EB', '-32', '-march=vr4300',
                        '-o', str(obj), str(source)], check=True, capture_output=True)
        return obj

    def test_exact_weak_alias_is_verified_without_an_extra_function(self):
        aliases = verify_procedures(self.assemble(), [record()])
        self.assertEqual(aliases, {'alias': {'value': 0, 'size': 8}})

    def test_partial_alias_and_unrecorded_procedure_fail(self):
        with self.assertRaisesRegex(ValueError, 'partial assembly procedure'):
            verify_procedures(self.assemble(alias_size=4), [record()])
        extra = ('.globl hidden\n.type hidden,@function\nhidden:\n'
                 'jr $ra\nnop\n.size hidden,.-hidden\n')
        with self.assertRaisesRegex(ValueError, 'Unrecorded'):
            verify_procedures(self.assemble(extra=extra), [record()])


if __name__ == '__main__':
    unittest.main()
