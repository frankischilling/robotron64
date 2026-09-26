from pathlib import Path
import sys
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "tools"))
from rom import normalize, validate
from verify import compare


class RomTests(unittest.TestCase):
    def test_three_orders_recover_known_bytes(self):
        canonical = bytes.fromhex("80371240") + bytes(range(60))
        swapped = b"".join(canonical[i:i + 2][::-1] for i in range(0, 64, 2))
        little = b"".join(canonical[i:i + 4][::-1] for i in range(0, 64, 4))
        for data in (canonical, swapped, little):
            self.assertEqual(normalize(data), canonical)

    def test_unknown_and_truncated_input_rejected(self):
        for data in (b"", bytes(64), bytes.fromhex("80371240") + bytes(61)):
            with self.assertRaises(ValueError):
                normalize(data)

    def test_wrong_target_rejected(self):
        with self.assertRaises(ValueError):
            validate(bytes(64))
        with self.assertRaisesRegex(ValueError, "sha1 mismatch"):
            validate(bytes.fromhex("80371240") + bytes(0x800000 - 4))

    def test_comparison_detects_corruption_and_truncation(self):
        compare(b"1234", b"1234")
        for data in (b"123", b"12345", b"12X4"):
            with self.assertRaises(ValueError):
                compare(b"1234", data)


if __name__ == "__main__":
    unittest.main()
