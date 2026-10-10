import hashlib
import struct
import sys
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / 'tools'))
from partition_context import retain_context

LAYOUT = {'prefix': (0, 8), 'target': (8, 12), 'suffix': (20, 8)}
READONLY = (8, hashlib.sha256(b'ABCDEFGH').hexdigest())


def fixture():
    data = bytearray(1024)
    data[:7] = b'\x7fELF\x01\x02\x01'
    struct.pack_into('>HHI', data, 16, 1, 8, 1)
    struct.pack_into('>I', data, 32, 52)
    struct.pack_into('>HHH', data, 46, 40, 7, 1)
    names = b'\0.shstrtab\0.text\0.rodata\0.rel.text\0.symtab\0.strtab\0'
    strings = b'\0prefix\0target\0suffix\0outside\0'
    data[336:336+len(names)] = names
    data[400:400+len(strings)] = strings
    labels = lambda name: names.index(name.encode()+b'\0')
    sections = [
        (0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
        (labels('.shstrtab'), 3, 0, 0, 336, len(names), 0, 0, 1, 0),
        (labels('.text'), 1, 6, 0, 448, 32, 0, 0, 16, 1),
        (labels('.rodata'), 1, 2, 0, 512, 8, 0, 0, 8, 0),
        (labels('.rel.text'), 9, 0, 0, 576, 24, 5, 2, 4, 8),
        (labels('.symtab'), 2, 0, 0, 640, 96, 6, 1, 4, 16),
        (labels('.strtab'), 3, 0, 0, 400, len(strings), 0, 0, 1, 0),
    ]
    for i, section in enumerate(sections):
        struct.pack_into('>10I', data, 52+i*40, *section)
    data[448:476] = struct.pack('>7I', 0x0C000000, 0, 0x0C000000,
                               0x03E00008, 0, 0x0C000000, 0)
    data[512:520] = b'ABCDEFGH'
    symbols = [(0, 0, 0, 0, 0, 0), (1, 0, 8, 0x12, 0, 2),
               (8, 8, 12, 0x12, 0, 2), (15, 20, 8, 0x12, 0, 2),
               (22, 0, 0, 0x10, 0, 0), (0, 0, 8, 3, 0, 3)]
    for i, symbol in enumerate(symbols):
        struct.pack_into('>IIIBBH', data, 640+i*16, *symbol)
    for i, relocation in enumerate([(0, 4 << 8 | 4), (8, 1 << 8 | 4), (20, 4 << 8 | 4)]):
        struct.pack_into('>II', data, 576+i*8, *relocation)
    return data


class ContextPartitionTests(unittest.TestCase):
    def test_preserves_complete_body_and_externalizes_both_context_sides(self):
        original = fixture()
        result = retain_context(bytes(original), 'target', LAYOUT, READONLY)
        self.assertEqual(result[448:460], original[456:468])
        self.assertEqual(struct.unpack_from('>I', result, 52+2*40+20)[0], 12)
        self.assertEqual(struct.unpack_from('>I', result, 52+3*40+20)[0], 0)
        self.assertEqual(struct.unpack_from('>II', result, 576), (0, 1 << 8 | 4))
        self.assertEqual(struct.unpack_from('>I', result, 52+4*40+20)[0], 8)
        for i in (1, 3):
            symbol = struct.unpack_from('>IIIBBH', result, 640+i*16)
            self.assertEqual(symbol[1:3], (0, 0))
            self.assertEqual(symbol[5], 0)
        self.assertEqual(struct.unpack_from('>IIIBBH', result, 672)[1:3], (0, 12))

    def reject(self, data, message):
        with self.assertRaisesRegex(ValueError, message):
            retain_context(bytes(data), 'target', LAYOUT, READONLY)

    def test_rejects_changed_context_extents_constants_and_live_tail(self):
        for position, value, message in [(656+8, 12, 'extent changed'),
                                         (52+2*40+20, 48, 'excessive alignment')]:
            data = fixture()
            struct.pack_into('>I', data, position, value)
            self.reject(data, message)
        data = fixture()
        data[512] ^= 1
        self.reject(data, 'constants changed')
        data = fixture()
        data[479] = 1
        self.reject(data, 'Unowned live text')

    def test_rejects_retained_references_to_discarded_data_or_nonzero_call_addends(self):
        data = fixture()
        struct.pack_into('>I', data, 588, 5 << 8 | 5)
        self.reject(data, 'context constants')
        data = fixture()
        struct.pack_into('>I', data, 456, 0x0C000001)
        self.reject(data, 'nonzero addend')

    def test_rejects_local_context_missing_function_and_malformed_relocation(self):
        data = fixture()
        data[656+12] = 2
        self.reject(data, 'global names')
        data = fixture()
        data[688+12] = 0x10
        self.reject(data, 'function set')
        data = fixture()
        struct.pack_into('>I', data, 584, 9)
        self.reject(data, 'Invalid relocation')


if __name__ == '__main__':
    unittest.main()
