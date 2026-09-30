from pathlib import Path
import sys
import tempfile
import unittest
from unittest.mock import patch

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / 'tools'))

from compare_startup import SymbolLayoutSnapshot, symbol_addresses


class ComparisonLayoutTests(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory()
        self.addCleanup(self.directory.cleanup)
        self.root = Path(self.directory.name)
        for name in SymbolLayoutSnapshot.files:
            path = self.root / name
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text('initial layout\n')

    def test_unchanged_layout_is_resolved_once(self):
        with patch('compare_startup.symbol_addresses', return_value={'target': 0x80001000}) as resolve:
            snapshot = SymbolLayoutSnapshot(self.root)
            snapshot.verify()
            snapshot.verify()
        self.assertEqual(resolve.call_count, 1)
        self.assertEqual(snapshot.addresses['target'], 0x80001000)

    def test_changed_layout_is_rejected_even_with_same_file_length(self):
        with patch('compare_startup.symbol_addresses', return_value={}):
            snapshot = SymbolLayoutSnapshot(self.root)
        path = self.root / 'config/functions.json'
        path.write_text('altered layout\n')
        with self.assertRaisesRegex(ValueError, 'Symbol layout changed'):
            snapshot.verify()

    def test_mutation_during_initial_resolution_is_rejected(self):
        def mutate(root):
            (root / 'config/owned_sections.json').write_text('changed while resolving\n')
            return {}
        with patch('compare_startup.symbol_addresses', side_effect=mutate):
            with self.assertRaisesRegex(ValueError, 'Symbol layout changed'):
                SymbolLayoutSnapshot(self.root)

    def test_source_function_rejects_an_absolute_binding_even_at_the_same_address(self):
        function = {'name': 'recovered', 'vram': 0x80001000}
        for filename in ('config/startup_symbols.ld', 'config/runtime_symbols.ld'):
            for address in (0x80001000, 0x80001004):
                with self.subTest(filename=filename, address=address):
                    for symbols in ('config/startup_symbols.ld', 'config/runtime_symbols.ld'):
                        (self.root / symbols).write_text('')
                    (self.root / filename).write_text(f'recovered = 0x{address:X};\n')
                    with patch('compare_startup.load_manifest', return_value=[function]), \
                            patch('compare_startup.load_owned_sections', return_value=[]):
                        with self.assertRaisesRegex(ValueError, 'Source-owned function has an absolute binding'):
                            symbol_addresses(self.root)

    def test_fallback_bindings_and_source_definitions_are_both_resolved(self):
        (self.root / 'config/startup_symbols.ld').write_text('fallback = 0x80002000;\n')
        (self.root / 'config/runtime_symbols.ld').write_text('')
        with patch('compare_startup.load_manifest', return_value=[{'name': 'recovered', 'vram': 0x80001000}]), \
                patch('compare_startup.load_owned_sections', return_value=[]):
            self.assertEqual(symbol_addresses(self.root), {
                'fallback': 0x80002000, 'recovered': 0x80001000,
            })


if __name__ == '__main__':
    unittest.main()
