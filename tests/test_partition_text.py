import struct
import sys
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / 'tools'))
from partition_text import retain_function


def fixture():
    data = bytearray(1024)
    data[:7] = b'\x7fELF\x01\x02\x01'
    struct.pack_into('>HHI', data, 16, 1, 8, 1)
    struct.pack_into('>I', data, 32, 52)
    struct.pack_into('>HHH', data, 46, 40, 6, 1)
    names = b'\0.shstrtab\0.text\0.rel.text\0.symtab\0.strtab\0'
    strings = b'\0decoder\0tick\0outside\0'
    data[320:320 + len(names)] = names
    data[384:384 + len(strings)] = strings
    sections = [
        (0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
        (1, 3, 0, 0, 320, len(names), 0, 0, 1, 0),
        (11, 1, 6, 0, 448, 32, 0, 0, 16, 1),
        (17, 9, 0, 0, 512, 24, 4, 2, 4, 8),
        (27, 2, 0, 0, 576, 64, 5, 1, 4, 16),
        (35, 3, 0, 0, 384, len(strings), 0, 0, 1, 0),
    ]
    for i, section in enumerate(sections):
        struct.pack_into('>10I', data, 52 + i * 40, *section)
    # Two complete functions, then eight bytes of raw zero alignment padding.
    data[448:472] = struct.pack('>6I', 0x3C010000, 0x03E00008, 0,
                               0x0C000000, 0x03E00008, 0)
    for i, symbol in enumerate([(0, 0, 0, 0, 0, 0), (1, 0, 12, 0x12, 0, 2),
                                (9, 12, 12, 0x12, 0, 2), (14, 0, 0, 0x10, 0, 0)]):
        struct.pack_into('>IIIBBH', data, 576 + i * 16, *symbol)
    for i, relocation in enumerate([(0, 3 << 8 | 5), (12, 1 << 8 | 4), (20, 3 << 8 | 6)]):
        struct.pack_into('>II', data, 512 + i * 8, *relocation)
    return data


class TextPartitionTests(unittest.TestCase):
    def test_retains_instructions_rebases_calls_and_externalizes_context(self):
        original = fixture()
        result = retain_function(bytes(original), 'tick', 'decoder', 20)
        self.assertEqual(result[448:468], original[460:472] + bytes(8))
        self.assertEqual(struct.unpack_from('>I', result, 52 + 2 * 40 + 20)[0], 20)
        self.assertEqual(struct.unpack_from('>II', result, 512), (0, 1 << 8 | 4))
        self.assertEqual(struct.unpack_from('>II', result, 520), (8, 3 << 8 | 6))
        self.assertEqual(struct.unpack_from('>I', result, 52 + 3 * 40 + 20)[0], 16)
        self.assertEqual(struct.unpack_from('>IIIBBH', result, 592), (1, 0, 0, 0x12, 0, 0))
        self.assertEqual(struct.unpack_from('>IIIBBH', result, 608), (9, 0, 12, 0x12, 0, 2))
        self.assertEqual(result[384:448], original[384:448])

    def reject(self, data, pattern):
        with self.assertRaisesRegex(ValueError, pattern):
            retain_function(bytes(data), 'tick', 'decoder', 20)

    def test_rejects_live_tail_and_excessive_padding(self):
        data = fixture()
        data[479] = 1
        self.reject(data, 'Unowned live text')
        data = fixture()
        struct.pack_into('>I', data, 52 + 2 * 40 + 20, 40)
        self.reject(data, 'Unowned live text')

    def test_rejects_changed_missing_or_overlapping_function_ranges(self):
        for position, value in [(608 + 4, 8), (608 + 8, 40), (592 + 4, 4),
                                (608, 14), (608 + 8, 0)]:
            data = fixture()
            struct.pack_into('>I', data, position, value)
            with self.subTest(position=position, value=value):
                with self.assertRaises(ValueError):
                    retain_function(bytes(data), 'tick', 'decoder', 20)

    def test_rejects_nonzero_context_addend(self):
        data = fixture()
        struct.pack_into('>I', data, 460, 0x0C000001)
        self.reject(data, 'nonzero addend')

    def test_rejects_reference_to_retained_text_or_wrong_relocation_kind(self):
        for info in (2 << 8 | 4, 1 << 8 | 5):
            data = fixture()
            struct.pack_into('>I', data, 524, info)
            self.reject(data, 'Unsupported reference')

    def test_rejects_relocation_into_padding_or_truncated_symbol_table(self):
        data = fixture()
        struct.pack_into('>I', data, 528, 24)
        self.reject(data, 'Relocation lies outside')
        self.reject(fixture()[:620], 'Truncated section')

    def test_rejects_local_context_and_overlong_retained_extent(self):
        data = fixture()
        data[592 + 12] = 2
        self.reject(data, 'must be global')
        for size in (8, 13, 28, 36):
            with self.subTest(size=size):
                with self.assertRaises(ValueError):
                    retain_function(bytes(fixture()), 'tick', 'decoder', size)


if __name__ == '__main__':
    unittest.main()
