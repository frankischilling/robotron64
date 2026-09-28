"""Synthetic ECOFF records; these tests contain no game or compiler binaries."""
from pathlib import Path
import struct
import sys
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "tools"))
from ido_symbols import parse_local_data, parse_local_functions


class IdoStaticProcedureTests(unittest.TestCase):
    def setUp(self):
        self.base = 16
        self.symbols = self.base + 96
        self.aux = self.symbols + 24
        self.strings = self.aux + 4
        self.files = self.strings + 8
        self.data = bytearray(self.files + 72)
        header = [0x7009, 0x313] + [0] * 23
        header[9:11] = [2, self.symbols]
        header[13:15] = [1, self.aux]
        header[15:17] = [8, self.strings]
        header[19:21] = [1, self.files]
        struct.pack_into(">2H23I", self.data, self.base, *header)
        struct.pack_into(">3I", self.data, self.symbols, 0, 4, (14 << 26) | (1 << 21))
        struct.pack_into(">3I", self.data, self.symbols + 12, 0, 16, (8 << 26) | (1 << 21))
        struct.pack_into(">I", self.data, self.aux, 2)
        self.data[self.strings:self.strings + 8] = b"helper\0\0"
        fd = [0] * 19
        fd[3], fd[5], fd[13] = 8, 2, 1
        struct.pack_into(">10I2H7I", self.data, self.files, *fd)

    def parse(self, data=None, text_size=32):
        data = self.data if data is None else data
        return parse_local_functions(data, self.base, len(data) - self.base, text_size)

    def test_uses_recorded_name_start_and_end_size(self):
        before = bytes(self.data)
        self.assertEqual(self.parse(), {"helper": (4, 16)})
        self.assertEqual(bytes(self.data), before)

    def test_external_procedure_and_nonprocedure_are_not_static_functions(self):
        for kind in (6, 2, 5):
            with self.subTest(kind=kind):
                data = bytearray(self.data)
                struct.pack_into(">I", data, self.symbols + 8, (kind << 26) | (1 << 21))
                self.assertEqual(self.parse(data), {})

    def test_requires_matching_start_end_names_and_back_reference(self):
        for change, message in ((7, "Empty"), (1, "name disagrees")):
            data = bytearray(self.data)
            struct.pack_into(">I", data, self.symbols + 12, change)
            with self.assertRaisesRegex(ValueError, message):
                self.parse(data)
        struct.pack_into(">I", self.data, self.symbols + 20, (8 << 26) | (1 << 21) | 1)
        with self.assertRaisesRegex(ValueError, "point to its start"):
            self.parse()

    def test_requires_live_aligned_range_inside_text(self):
        for start, size in ((4, 0), (5, 16), (4, 15), (20, 16)):
            with self.subTest(start=start, size=size):
                data = bytearray(self.data)
                struct.pack_into(">I", data, self.symbols + 4, start)
                struct.pack_into(">I", data, self.symbols + 16, size)
                with self.assertRaisesRegex(ValueError, "text section"):
                    self.parse(data)

    def test_rejects_auxiliary_and_end_indices_outside_file(self):
        data = bytearray(self.data)
        struct.pack_into(">I", data, self.symbols + 8, (14 << 26) | (1 << 21) | 1)
        with self.assertRaisesRegex(ValueError, "auxiliary index"):
            self.parse(data)
        for value in (0, 1, 3, 0xFFFFFFFF):
            data = bytearray(self.data)
            struct.pack_into(">I", data, self.aux, value)
            with self.assertRaisesRegex(ValueError, "end index"):
                self.parse(data)

    def test_rejects_bad_storage_class_and_end_kind(self):
        for at, flags in ((self.symbols + 8, (14 << 26) | (3 << 21)),
                          (self.symbols + 20, (7 << 26) | (1 << 21))):
            data = bytearray(self.data)
            struct.pack_into(">I", data, at, flags)
            with self.assertRaises(ValueError):
                self.parse(data)

    def test_rejects_tables_outside_debug_section_and_file_slices(self):
        for header_word in (9, 13, 15, 19):
            data = bytearray(self.data)
            struct.pack_into(">I", data, self.base + header_word * 4, len(data))
            with self.assertRaisesRegex(ValueError, "table extent"):
                self.parse(data)
        struct.pack_into(">I", self.data, self.files + 8, 1)
        with self.assertRaisesRegex(ValueError, "leaves its tables"):
            self.parse()

    def test_rejects_unterminated_string_invalid_magic_and_truncation(self):
        data = bytearray(self.data)
        data[self.strings:self.strings + 8] = b"abcdefgh"
        with self.assertRaisesRegex(ValueError, "Unterminated"):
            self.parse(data)
        data = bytearray(self.data)
        struct.pack_into(">H", data, self.base, 0)
        with self.assertRaisesRegex(ValueError, "magic"):
            self.parse(data)
        with self.assertRaisesRegex(ValueError, "header"):
            self.parse(self.data[:40])

    def test_private_data_records_preserve_names_offsets_and_storage_class(self):
        for storage, section in ((2, ".data"), (3, ".bss"), (15, ".rodata")):
            data = bytearray(self.data)
            struct.pack_into(">I", data, self.symbols + 8, (2 << 26) | (storage << 21) | 0xFFFFF)
            self.assertEqual(parse_local_data(data, self.base, len(data) - self.base,
                                              {section: 8}), {"helper": (section, 4)})
            self.assertEqual(parse_local_functions(data, self.base, len(data) - self.base, 32), {})

    def test_private_data_requires_an_allocated_extent_and_unique_name(self):
        struct.pack_into(">I", self.data, self.symbols + 8, (2 << 26) | (2 << 21) | 0xFFFFF)
        for sizes in ({}, {".data": 4}):
            with self.assertRaisesRegex(ValueError, "leaves its section"):
                parse_local_data(self.data, self.base, len(self.data) - self.base, sizes)
        struct.pack_into(">I", self.data, self.symbols + 20, (2 << 26) | (2 << 21) | 0xFFFFF)
        with self.assertRaisesRegex(ValueError, "Ambiguous static data"):
            parse_local_data(self.data, self.base, len(self.data) - self.base, {".data": 32})
