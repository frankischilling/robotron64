from pathlib import Path
import sys
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "tools"))
from progress import parse_sections, verify_section


class SectionPlacementTests(unittest.TestCase):
    def setUp(self):
        self.function = {"name": "example", "rom": 0x1010, "vram": 0x80000410,
                         "size": 16, "section_vram": 0x80000400, "section": ".example"}
        self.sections = {".example": (0x30, 0x80000400, 0x1000)}

    def test_parses_gnu_section_headers_and_accepts_correct_placement(self):
        output = """Sections:
Idx Name          Size      VMA       LMA       File off  Algn
  2 .example      00000030  80000400  00001000  00002000  2**4
                  CONTENTS, ALLOC, LOAD, READONLY, CODE
"""
        self.assertEqual(parse_sections(output), self.sections)
        verify_section(self.function, self.sections)
        with self.assertRaisesRegex(ValueError, "No ELF section"):
            parse_sections("not section headers")

    def test_rejects_wrong_load_address_with_unchanged_vma_and_size(self):
        self.sections[".example"] = (0x30, 0x80000400, 0x2000)
        with self.assertRaisesRegex(ValueError, "VMA/LMA"):
            verify_section(self.function, self.sections)

    def test_rejects_wrong_runtime_address(self):
        self.sections[".example"] = (0x30, 0x80000500, 0x1000)
        with self.assertRaisesRegex(ValueError, "VMA/LMA"):
            verify_section(self.function, self.sections)

    def test_rejects_missing_or_truncated_section(self):
        with self.assertRaisesRegex(ValueError, "Missing linked section"):
            verify_section(self.function, {})
        self.sections[".example"] = (0x1C, 0x80000400, 0x1000)
        with self.assertRaisesRegex(ValueError, "outside linked section"):
            verify_section(self.function, self.sections)
