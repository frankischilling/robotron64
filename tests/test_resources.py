import hashlib
from pathlib import Path
import struct
import sys
import tempfile
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "tools"))
from resources import extract, inventory, parse_directory, rebuild, resource_path


class ResourceTests(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory()
        self.addCleanup(self.directory.cleanup)
        self.root = Path(self.directory.name)
        self.data = bytearray(b"\xCC" * 112)
        struct.pack_into("<I", self.data, 8, 2)
        for index, (name, offset, payload) in enumerate((
            (b"MODELS\\EXAMPLE.DAT", 80, b"model!"),
            (b"LEVEL1.STR", 92, b"level"),
        )):
            entry = 12 + index * 32
            self.data[entry:entry + 32] = bytes(32)
            self.data[entry + 1:entry + 1 + len(name)] = name
            struct.pack_into("<II", self.data, entry + 24, offset - 8, len(payload))
            self.data[offset:offset + len(payload)] = payload

    def parse(self):
        return parse_directory(bytes(self.data), base=8)

    def test_little_endian_directory_and_payloads(self):
        entries = self.parse()
        self.assertEqual([(entry.offset, entry.size) for entry in entries],
                         [(80, 6), (92, 5)])
        report = inventory(self.data, entries, base=8)
        self.assertEqual(report["directory_end"], 76)
        self.assertEqual(report["resources"][0]["path"], "MODELS/EXAMPLE.DAT")
        self.assertEqual(report["resources"][1]["sha256"],
                         hashlib.sha256(b"level").hexdigest())

    def test_extraction_round_trip_preserves_padding_and_header(self):
        entries = self.parse()
        extract(self.data, entries, self.root)
        self.assertEqual((self.root / "MODELS/EXAMPLE.DAT").read_bytes(), b"model!")
        self.assertEqual(rebuild(self.data, entries, self.root), bytes(self.data))
        extract(self.data, entries, self.root)

    def test_existing_modified_resource_is_preserved(self):
        entries = self.parse()
        (self.root / "LEVEL1.STR").write_bytes(b"edited")
        with self.assertRaisesRegex(ValueError, "Existing extracted resource differs"):
            extract(self.data, entries, self.root)
        self.assertEqual((self.root / "LEVEL1.STR").read_bytes(), b"edited")
        self.assertFalse((self.root / "MODELS").exists())

    def test_rebuild_checks_size_and_allows_fixed_size_changes(self):
        entries = self.parse()
        extract(self.data, entries, self.root)
        (self.root / "LEVEL1.STR").write_bytes(b"other")
        changed = rebuild(self.data, entries, self.root)
        self.assertEqual(changed[92:97], b"other")
        self.assertEqual(changed[:92], self.data[:92])
        self.assertEqual(changed[97:], self.data[97:])
        (self.root / "LEVEL1.STR").write_bytes(b"too large")
        with self.assertRaisesRegex(ValueError, "Resource size changed"):
            rebuild(self.data, entries, self.root)

    def test_directory_count_is_bounded_before_reading_entries(self):
        struct.pack_into("<I", self.data, 8, 0xFFFFFFFF)
        with self.assertRaisesRegex(ValueError, "entries extend beyond"):
            self.parse()

    def test_resource_bounds_and_overlap(self):
        for relative, size, message in ((1, 6, "outside"), (90, 30, "outside"),
                                        (80, 9, "overlap")):
            with self.subTest(relative=relative, size=size):
                struct.pack_into("<II", self.data, 12 + 24, relative, size)
                with self.assertRaisesRegex(ValueError, message):
                    self.parse()

    def test_case_insensitive_path_collision(self):
        self.data[45:68] = b"models/example.dat\0".ljust(23, b"\0")
        with self.assertRaisesRegex(ValueError, "more than once"):
            self.parse()

    def test_requires_terminated_ascii_name(self):
        self.data[13:36] = b"a" * 23
        with self.assertRaisesRegex(ValueError, "no name terminator"):
            self.parse()
        self.data[13:36] = b"\xFF\0".ljust(23, b"\0")
        with self.assertRaisesRegex(ValueError, "non-ASCII"):
            self.parse()

    def test_resource_file_cannot_also_be_a_directory(self):
        self.data[13:36] = b"MODELS\0".ljust(23, b"\0")
        self.data[45:68] = b"models/example.dat\0".ljust(23, b"\0")
        with self.assertRaisesRegex(ValueError, "conflicts with a directory"):
            self.parse()

    def test_rejects_unsafe_or_ambiguous_paths(self):
        for name in ("../outside", "\\absolute", "C:\\file", "a//b", "a/./b",
                     "a/../b", "a.", "NUL.txt", "a/COM1", "a:b", ""):
            with self.subTest(name=name), self.assertRaises(ValueError):
                resource_path(name)

    def test_symlink_cannot_redirect_payload_outside_root(self):
        outside = self.root / "outside"
        outside.mkdir()
        target = self.root / "assets"
        target.mkdir()
        (target / "MODELS").symlink_to(outside, target_is_directory=True)
        with self.assertRaisesRegex(ValueError, "leaves the output"):
            extract(self.data, self.parse(), target)
        self.assertFalse((outside / "EXAMPLE.DAT").exists())


if __name__ == "__main__":
    unittest.main()
