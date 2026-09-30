import sys
from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "tools"))
from generate_video_modes import REGIONS, VARIANTS, mode_words, render_modes


class VideoModeTests(unittest.TestCase):
    def test_all_regions_and_variants_have_complete_records(self):
        self.assertEqual(len(REGIONS) * len(VARIANTS), 42)
        for region in REGIONS:
            for variant in range(14):
                words = mode_words(region, variant)
                self.assertEqual(len(words), 19)
                self.assertTrue(all(0 <= word < 2**32 for word in words))
                self.assertEqual(words[13], 2)
                self.assertEqual(words[18], 2)

    def test_depth_changes_origin_and_retains_timing(self):
        for region in REGIONS:
            first = mode_words(region, 0)
            wide_pixel = mode_words(region, 4)
            self.assertEqual(first[2:9], wide_pixel[2:9])
            self.assertEqual(wide_pixel[9], first[9] * 2)
            self.assertEqual(wide_pixel[14], first[14] * 2)
            self.assertEqual(first[0] & 3, 2)
            self.assertEqual(wide_pixel[0] & 3, 3)

    def test_filtered_field_offsets(self):
        for region in REGIONS:
            low = mode_words(region, 1)
            high = mode_words(region, 9)
            self.assertEqual((low[10], low[15]), (0x01000400, 0x03000400))
            self.assertEqual((high[10], high[15]), (0x02000800, 0x02000800))
            self.assertEqual(high[14], high[9] * 2)

    def test_committed_sources_are_reproducible(self):
        for filename, defaults in [("video_modes.c", False), ("video_default_modes.c", True)]:
            self.assertEqual((ROOT / "src/sdk" / filename).read_text(), render_modes(defaults))


if __name__ == "__main__":
    unittest.main()
