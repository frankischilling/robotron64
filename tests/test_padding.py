import sys
import struct
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / 'tools'))
from trim_padding import trim


def fixture(tail=b'\0' * 8, relocation=0, symbol_type=3):
    data = bytearray(512)
    data[:6] = b'\x7fELF\x01\x02'
    struct.pack_into('>I', data, 32, 52)
    struct.pack_into('>HHH', data, 46, 40, 5, 1)
    names = b'\0.shstrtab\0.rodata\0.rel.rodata\0.symtab\0'
    data[256:256 + len(names)] = names
    sections = [
        (0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
        (1, 3, 0, 0, 256, len(names), 0, 0, 1, 0),
        (11, 1, 2, 0, 320, 16, 0, 0, 16, 0),
        (19, 9, 0, 0, 352, 8, 4, 2, 4, 8),
        (31, 2, 0, 0, 384, 16, 1, 1, 4, 16),
    ]
    for i, section in enumerate(sections):
        struct.pack_into('>10I', data, 52 + i * 40, *section)
    data[320:336] = b'abcdefgh' + tail
    struct.pack_into('>II', data, 352, relocation, 2)
    struct.pack_into('>IIIBBH', data, 384, 0, 0, 16, symbol_type, 0, 2)
    return bytes(data)


class PaddingTests(unittest.TestCase):
    def test_preserves_payload_and_relocations_updates_section_symbol(self):
        original = fixture()
        result = trim(original, '.rodata', 8)
        self.assertEqual(result[320:384], original[320:384])
        self.assertEqual(struct.unpack_from('>I', result, 52 + 2 * 40 + 20)[0], 8)
        self.assertEqual(struct.unpack_from('>I', result, 384 + 8)[0], 8)

    def test_rejects_live_tail(self):
        with self.assertRaisesRegex(ValueError, 'zero alignment'):
            trim(fixture(tail=b'12345678'), '.rodata', 8)

    def test_rejects_relocation_in_tail(self):
        with self.assertRaisesRegex(ValueError, 'Relocation'):
            trim(fixture(relocation=8), '.rodata', 8)

    def test_rejects_object_symbol_spanning_tail(self):
        with self.assertRaisesRegex(ValueError, 'Symbol'):
            trim(fixture(symbol_type=1), '.rodata', 8)

    def test_rejects_wrong_format_missing_section_and_truncation(self):
        for data, name in [(b'', '.rodata'), (fixture(), '.missing'), (fixture()[:100], '.rodata')]:
            with self.subTest(name=name, length=len(data)):
                with self.assertRaises(ValueError):
                    trim(data, name, 8)
