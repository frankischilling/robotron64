from pathlib import Path
import sys
import tempfile
import unittest
from unittest.mock import patch

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / 'tools'))

from compare_startup import SymbolLayoutSnapshot


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


if __name__ == '__main__':
    unittest.main()
