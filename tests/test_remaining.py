from pathlib import Path
import sys
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "tools"))
from remaining import inventory, partition


class RemainingTests(unittest.TestCase):
    CPU = {"rom_start": 0x100, "rom_end": 0x200, "vram_start": 0x80000400}

    def record(self, first, last, name="example"):
        return {"name": name, "rom_start": first, "rom_end": last, "kind": "fallback"}

    def test_clips_ranges_and_maps_runtime_addresses(self):
        items, gaps = partition(self.CPU, [self.record(0xF0, 0x120),
                                          self.record(0x1F0, 0x240, "last")])
        self.assertEqual([(r["rom_start"], r["rom_end"]) for r in items],
                         [(0x100, 0x120), (0x1F0, 0x200)])
        self.assertEqual(items[1]["vram_start"], 0x800004F0)
        self.assertEqual(items[1]["vram_end"], 0x80000500)
        self.assertEqual(gaps, [{"rom_start": 0x120, "rom_end": 0x1F0,
                                "vram_start": 0x80000420, "vram_end": 0x800004F0,
                                "bytes": 0xD0}])

    def test_ignores_ranges_outside_candidate(self):
        items, gaps = partition(self.CPU, [self.record(0, 0x100),
                                          self.record(0x200, 0x300)])
        self.assertEqual(items, [])
        self.assertEqual(gaps[0]["bytes"], 0x100)

    def test_adjacent_unsorted_intervals_have_no_gap(self):
        items, gaps = partition(self.CPU, [self.record(0x180, 0x200, "last"),
                                          self.record(0x100, 0x180)])
        self.assertEqual([r["name"] for r in items], ["example", "last"])
        self.assertEqual(gaps, [])

    def test_rejects_partial_and_nested_ownership_overlap(self):
        for first, last in [(0x140, 0x180), (0x110, 0x120), (0x100, 0x150)]:
            with self.subTest(first=first, last=last):
                with self.assertRaisesRegex(ValueError, "Overlapping"):
                    partition(self.CPU, [self.record(0x100, 0x150),
                                         self.record(first, last, "conflict")])

    def test_rejects_invalid_cpu_bounds_and_noninteger_fields(self):
        for change in [{"rom_start": -1}, {"rom_end": 0x100},
                       {"vram_start": 0xFFFFFFF0}, {"rom_end": True}]:
            with self.subTest(change=change), self.assertRaises(ValueError):
                partition(dict(self.CPU, **change), [])

    def test_rejects_invalid_intervals_even_outside_candidate(self):
        for first, last in [(0, 0), (-1, 4), (4, 2), (True, 8)]:
            with self.subTest(first=first, last=last), self.assertRaisesRegex(ValueError, "Invalid interval"):
                partition(self.CPU, [self.record(first, last)])

    def test_accounts_for_all_categories_without_establishing_code_total(self):
        functions = [{"name": "c", "rom": 0x100, "size": 0x20, "source": "c.c"},
                     {"name": "asm", "rom": 0x120, "size": 0x10,
                      "language": "assembly", "source": "asm.s"}]
        owned = [{"section": ".data", "rom": 0x130, "size": 0x10, "source": "c.c"},
                 {"section": ".bss", "rom": None, "size": 0x500, "source": "c.c"}]
        report = inventory(self.CPU, functions, owned, [("remaining", 0x150, 0x200)])
        self.assertEqual(report["declared_bytes"], {"C": 32, "assembly": 16,
                         "initialized_data": 16, "fallback": 176,
                         "unclassified": 16, "candidate_range": 256})
        self.assertIsNone(report["total_code_bytes"])
        self.assertIsNone(report["total_functions"])
        self.assertIsNone(report["matching_code_percent"])

    def test_sorts_fallback_by_size_then_address(self):
        report = inventory(self.CPU, [], [], [("later", 0x180, 0x190),
                                            ("largest", 0x130, 0x160),
                                            ("earlier", 0x110, 0x120)])
        self.assertEqual([r["name"] for r in report["fallback_ranges"]],
                         ["largest", "earlier", "later"])

    def test_rejects_source_and_fallback_overlap(self):
        with self.assertRaisesRegex(ValueError, "Overlapping"):
            inventory(self.CPU, [{"name": "c", "rom": 0x100, "size": 16,
                                 "source": "c.c"}], [], [("fallback", 0x108, 0x120)])

    def test_rejects_unknown_source_language(self):
        with self.assertRaisesRegex(ValueError, "Unsupported"):
            inventory(self.CPU, [{"name": "c", "rom": 0x100, "size": 16,
                                 "source": "c.c", "language": "unknown"}], [], [])
