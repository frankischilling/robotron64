from pathlib import Path
import sys
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "tools"))
from compare_startup import external_assignments


class ComparisonSymbolTests(unittest.TestCase):
    def test_only_unresolved_symbols_receive_absolute_assignments(self):
        known = {"source_function": 0x80000400, "external_function": 0x80000500}
        script = external_assignments({"external_function"}, known)
        self.assertEqual(script, "external_function = 0x80000500;\n")
        self.assertNotIn("source_function", script)

    def test_address_named_references_are_supported(self):
        script = external_assignments({"func_8005018C", "D_FLT_80094C20"}, {})
        self.assertIn("func_8005018C = 0x8005018C;", script)
        self.assertIn("D_FLT_80094C20 = 0x80094C20;", script)

    def test_unknown_alias_and_conflicting_address_are_rejected(self):
        with self.assertRaisesRegex(ValueError, "No recorded address"):
            external_assignments({"unresolved_alias"}, {})
        with self.assertRaisesRegex(ValueError, "disagrees"):
            external_assignments({"func_8005018C"}, {"func_8005018C": 0x80050190})
