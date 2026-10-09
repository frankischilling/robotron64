from pathlib import Path
import struct
import sys
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / 'tools'))
from actor_ring_model import (
    CURSOR, DL_CURSOR, DLIST, POOL, initial, locate, oracle, scaled_sine,
    signed, u32, vector,
)


class ActorRingModelTests(unittest.TestCase):
    def model(self, state=1, first=137, mode=1):
        case = (state, first, mode, 3, 0, 0)
        data, info = initial(case)
        expected, allowed, trace, result = oracle(data, case, info)
        return data, info, expected, trace, result

    def test_quadrant_endpoints_and_signed_low_words(self):
        self.assertEqual([scaled_sine(a) for a in (0, 1023, 1024, 2047, 2048, 3071, 3072, 4095)],
                         [0, 4095, 4095, 0, 0, -4095, -4095, 0])
        self.assertEqual(signed(0xFFFFFFFF), -1)
        self.assertEqual(signed(0x180000000), -2147483648)

    def test_two_rings_keep_texture_fields_and_arithmetic_shift_asymmetry(self):
        data, info, expected, trace, result = self.model()
        base = POOL + 137 * 16
        block, offset = locate(expected, base, 32 * 16)
        original, old_offset = locate(data, base, 32 * 16)
        self.assertEqual(struct.unpack('>3h', block[offset:offset + 6]), (299, 100, 0))
        self.assertEqual(struct.unpack('>3h', block[offset + 16:offset + 22]), (299, 300, 0))
        self.assertEqual(struct.unpack('>3h', block[offset + 16 * 16:offset + 16 * 16 + 6]),
                         (-300, 100, 0))
        for vertex in range(32):
            start, old = offset + vertex * 16, old_offset + vertex * 16
            self.assertEqual(block[start + 6:start + 12], original[old + 6:old + 12])
            self.assertEqual(block[start + 12:start + 16], bytes((17, 93, 201, 198)))
        self.assertEqual(vector(expected, info['object'] + 0x60), (6166, -3383, 2266))
        self.assertEqual(result, 0)

    def test_triangle_winding_and_last_quad_wrap(self):
        data, info, expected, trace, result = self.model()
        block, offset = locate(expected, DLIST, 272)
        packets = list(struct.iter_unpack('>II', block[offset:offset + 272]))
        self.assertEqual(packets[1], (0x040081FF, POOL + 137 * 16))
        self.assertEqual(packets[2:4], [(0xB1040602, 0x00040200), (0xB1020604, 0x00020400)])
        self.assertEqual(packets[-2:], [(0xB100023E, 0x00003E3C), (0xB13E0200, 0x003E003C)])
        self.assertEqual(u32(expected, DL_CURSOR), DLIST + 272)

    def test_allocation_failure_precedes_actor_and_palette_reads(self):
        for first in (-1, 9801):
            data, info, expected, trace, result = self.model(first=first, mode=18)
            self.assertEqual(result, 1)
            self.assertEqual(u32(expected, CURSOR), 0xFFFFFFFF)
            self.assertEqual([call[0] for call in trace[:3]], [0x8004729C, 0x80046774, 0x80047048])
            self.assertEqual(len(trace), 4 if first == 9801 else 3)
            self.assertEqual(u32(expected, DL_CURSOR), DLIST + 48)
            self.assertEqual(vector(expected, info['object'] + 0x54), (12345, -6789, 4567))

    def test_low_word_wrap_and_alpha_clamp(self):
        for state, expected_alpha, expected_x in ((20, 10, 3149), (-2147483648, 208, 149)):
            data, info, expected, trace, result = self.model(state=state)
            block, offset = locate(expected, POOL + 137 * 16, 16)
            self.assertEqual(block[offset + 15], expected_alpha)
            self.assertEqual(struct.unpack('>h', block[offset:offset + 2])[0], expected_x)


if __name__ == '__main__':
    unittest.main()
