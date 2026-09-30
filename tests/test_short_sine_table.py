import sys
from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "tools"))
from generate_short_sine_table import render_table, table_values


class ShortSineTableTests(unittest.TestCase):
    def test_mathematical_range_and_endpoints(self):
        values = table_values()
        self.assertEqual(len(values), 1024)
        self.assertEqual(values[:4], [0, 50, 100, 150])
        self.assertEqual(values[-4:], [32766, 32766, 32766, 32767])
        self.assertTrue(all(0 <= value <= 32767 for value in values))
        self.assertTrue(all(first <= second for first, second in zip(values, values[1:])))

    def test_committed_declaration_is_reproducible(self):
        self.assertTrue((ROOT / "src/sdk/short_sine.c").read_text().endswith(render_table()))


if __name__ == "__main__":
    unittest.main()
