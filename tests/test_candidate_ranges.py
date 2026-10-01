from pathlib import Path
import sys
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "tools"))

from compare_runtime import CANDIDATE_BLOCKS, validate_candidate_ranges
from manifest import load_manifest


class CandidateRangeTests(unittest.TestCase):
    recovered = [{"name": "recovered", "vram": 0x80001000, "size": 16}]

    def test_rejects_exact_partial_and_enclosing_recovered_ranges(self):
        for start, end in [(0x80001000, 0x80001010),
                           (0x8000100C, 0x80001014),
                           (0x80000FFC, 0x80001004),
                           (0x80000FFC, 0x80001014)]:
            with self.subTest(start=start, end=end):
                with self.assertRaisesRegex(ValueError, "overlaps recovered function recovered"):
                    validate_candidate_ranges([("probe", "probe.c", start, end)], self.recovered)

    def test_allows_adjacent_unrecovered_ranges(self):
        validate_candidate_ranges([
            ("before", "before.c", 0x80000FFC, 0x80001000),
            ("after", "after.c", 0x80001010, 0x80001014),
        ], self.recovered)

    def test_rejects_empty_reversed_and_unaligned_instruction_ranges(self):
        for start, end in [(16, 16), (20, 16), (17, 20), (16, 21)]:
            with self.subTest(start=start, end=end):
                with self.assertRaisesRegex(ValueError, "Invalid candidate instruction range"):
                    validate_candidate_ranges([("probe", "probe.c", start, end)], [])

    def test_current_candidates_do_not_cover_recovered_functions(self):
        validate_candidate_ranges(CANDIDATE_BLOCKS, load_manifest())


if __name__ == "__main__":
    unittest.main()
