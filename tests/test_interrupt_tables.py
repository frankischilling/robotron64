from pathlib import Path
import sys
import unittest

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "tools"))
from generate_interrupt_tables import cpu_offsets, rcp_mask, render_cpu_tables, render_rcp_masks


class InterruptTableTests(unittest.TestCase):
    def test_cpu_offsets_choose_highest_pending_interrupt(self):
        offsets = cpu_offsets()
        self.assertEqual(len(offsets), 32)
        for bits in range(16):
            if bits:
                highest = max(index for index in range(4) if bits & (1 << index))
                self.assertEqual(offsets[bits], 20 + highest * 4)
                self.assertEqual(offsets[16 + bits], 4 + highest * 4)
            else:
                self.assertEqual((offsets[bits], offsets[16 + bits]), (0, 0))

    def test_all_rcp_masks_select_exactly_one_bit_per_interrupt(self):
        for bits in range(64):
            word = rcp_mask(bits)
            for interrupt in range(6):
                self.assertEqual((word >> (interrupt * 2)) & 3,
                                 2 if bits & (1 << interrupt) else 1)
            self.assertEqual(word >> 12, 0)
        self.assertEqual((rcp_mask(0), rcp_mask(63)), (0x555, 0xAAA))

    def test_rcp_mask_rejects_outside_six_bit_range(self):
        for value in [-1, 64, 255]:
            with self.assertRaises(ValueError):
                rcp_mask(value)

    def test_committed_interrupt_sources_are_reproducible(self):
        for filename, render in [("cpu_interrupt_tables.c", render_cpu_tables),
                                 ("rcp_interrupt_masks.c", render_rcp_masks)]:
            self.assertEqual((ROOT / "src/sdk" / filename).read_text(), render())


if __name__ == "__main__":
    unittest.main()
