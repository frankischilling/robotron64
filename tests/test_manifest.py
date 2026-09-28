import copy
from pathlib import Path
import sys
import tempfile
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "tools"))
from manifest import validate_manifest


class ManifestTests(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory()
        self.addCleanup(self.directory.cleanup)
        self.root = Path(self.directory.name)
        (self.root / "src").mkdir()
        (self.root / "docs").mkdir()
        (self.root / "src/example.c").write_text("void example(void) {}\n")
        (self.root / "docs/example.md").write_text("Synthetic test evidence.\n")
        self.function = {
            "name": "example", "rom": 0x1000, "vram": 0x80000400,
            "size": 16, "section_vram": 0x80000400, "section": ".example",
            "source": "src/example.c", "object": "build/example.o",
            "evidence": "docs/example.md",
        }

    def check(self, functions):
        return validate_manifest(functions, 0x800000, self.root)

    def test_valid_metadata_needs_no_rom_or_built_object(self):
        functions = [self.function]
        self.assertIs(self.check(functions), functions)
        self.assertFalse((self.root / "build/example.o").exists())

    def test_rejects_missing_source_and_evidence(self):
        for field in ("source", "evidence"):
            with self.subTest(field=field):
                function = dict(self.function, **{field: "missing.md"})
                with self.assertRaisesRegex(ValueError, "Missing " + field):
                    self.check([function])

    def test_rejects_duplicate_names_and_overlapping_ranges(self):
        with self.assertRaisesRegex(ValueError, "Duplicate"):
            self.check([self.function, copy.deepcopy(self.function)])
        other = dict(self.function, name="other", rom=0x1008, vram=0x80000408)
        with self.assertRaisesRegex(ValueError, "Overlapping"):
            self.check([self.function, other])

    def test_rejects_malformed_out_of_bounds_and_unaligned_ranges(self):
        for change, message in [
            ({"rom": True}, "integer"), ({"size": 0}, "Invalid ROM"),
            ({"rom": -4}, "Invalid ROM"), ({"size": 0x800000}, "Invalid ROM"),
            ({"section_vram": 0x80000404}, "runtime"),
            ({"vram": 0xFFFFFFFC}, "runtime"), ({"size": 15}, "Unaligned"),
        ]:
            with self.subTest(change=change):
                with self.assertRaisesRegex(ValueError, message):
                    self.check([dict(self.function, **change)])

    def test_rejects_inconsistent_load_address_within_section(self):
        other = dict(self.function, name="other", rom=0x1020, vram=0x80000410)
        with self.assertRaisesRegex(ValueError, "section placement"):
            self.check([self.function, other])
        other["rom"] = 0x1010
        self.check([self.function, other])

    def test_rejects_invalid_languages_and_source_extensions(self):
        for change, message in [({"language": "unknown"}, "Unsupported"),
                                ({"language": "assembly"}, "extension")]:
            with self.subTest(change=change):
                with self.assertRaisesRegex(ValueError, message):
                    self.check([dict(self.function, **change)])
        (self.root / "src/entry.s").write_text(".text\n")
        self.check([dict(self.function, source="src/entry.s", language="assembly")])

    def test_rejects_conflicting_sources_for_one_object(self):
        (self.root / "src/other.c").write_text("void other(void) {}\n")
        other = dict(self.function, name="other", rom=0x1010, vram=0x80000410,
                     source="src/other.c")
        with self.assertRaisesRegex(ValueError, "Conflicting source"):
            self.check([self.function, other])

    def test_accepts_explicit_static_c_but_rejects_unknown_linkage(self):
        self.check([dict(self.function, linkage="static")])
        with self.assertRaisesRegex(ValueError, "linkage"):
            self.check([dict(self.function, linkage="unknown")])
        (self.root / "src/entry.s").write_text(".text\n")
        with self.assertRaisesRegex(ValueError, "linkage"):
            self.check([dict(self.function, source="src/entry.s", language="assembly",
                             linkage="static")])

    def test_rejects_invalid_record_shapes_and_paths(self):
        for functions in ([], {}, [None], [{"name": "incomplete"}]):
            with self.subTest(functions=functions):
                with self.assertRaises(ValueError):
                    self.check(functions)
        for field in ("source", "object", "evidence"):
            for path in ("../outside.c", "/outside.c", "C:/outside.c", "src\\example.c"):
                with self.subTest(field=field, path=path):
                    with self.assertRaises(ValueError):
                        self.check([dict(self.function, **{field: path})])
