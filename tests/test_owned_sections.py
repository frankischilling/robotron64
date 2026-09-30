import copy
import json
from pathlib import Path
import shutil
import struct
import subprocess
import sys
import tempfile
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "tools"))
from owned_sections import (load_owned_sections, linker_placements,
                            validate_function_ranges, verify_owned_binary)


def record(bss=False):
    return {"source": "src/example.c", "object": "build/us/example.o",
            "evidence": "docs/example.md", "input_section": ".bss" if bss else ".data",
            "section": ".example", "vram": 0x80002000,
            "rom": None if bss else 0x20, "size": 4,
            "symbols": {"D_80002000": 0}}


def elf_fixture(entry, linked=True, absolute=False, wrong_type=False):
    """A small valid section/symbol layout, independent of a host MIPS compiler."""
    data = bytearray(768)
    data[:6] = b"\x7fELF\x01\x02"
    struct.pack_into(">I", data, 32, 52)
    struct.pack_into(">HHH", data, 46, 40, 5, 1)
    name = entry["section"] if linked else entry["input_section"]
    names = b"\0.shstrtab\0.strtab\0.symtab\0" + name.encode() + b"\0"
    symbol_names = b"\0D_80002000\0"
    data[256:256 + len(names)] = names
    data[384:384 + len(symbol_names)] = symbol_names
    address = entry["vram"] if linked else 0
    section_type = 8 if entry["rom"] is None else 1
    sections = [
        (0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
        (1, 3, 0, 0, 256, len(names), 0, 0, 1, 0),
        (11, 3, 0, 0, 384, len(symbol_names), 0, 0, 1, 0),
        (19, 2, 0, 0, 448, 32, 2, 1, 4, 16),
        (27, section_type, 3, address, 512, 4, 0, 0, 4, 0),
    ]
    for index, section in enumerate(sections):
        struct.pack_into(">10I", data, 52 + index * 40, *section)
    struct.pack_into(">IIIBBH", data, 464, 1, address, 4,
                     0x10 if wrong_type else 0x11, 0, 0xFFF1 if absolute else 4)
    data[512:516] = b"\x01\x02\x03\x04"
    return bytes(data)


def private_elf_fixture(entry):
    """Relocatable data with an IDO static variable and no global object symbol."""
    data = bytearray(elf_fixture(entry, linked=False))
    data.extend(bytes(640))
    data[6] = 1
    struct.pack_into(">HH", data, 16, 1, 8)
    sections = [list(struct.unpack_from(">10I", data, 52 + index * 40)) for index in range(5)]
    names_end = sections[1][5]
    data[256 + names_end:256 + names_end + 8] = b".mdebug\0"
    sections[1][5] += 8
    sections.append([names_end, 0x70000005, 0, 0, 1024, 188, 0, 0, 4, 0])
    struct.pack_into(">I", data, 32, 768)
    struct.pack_into(">H", data, 48, 6)
    for index, section in enumerate(sections):
        struct.pack_into(">10I", data, 768 + index * 40, *section)
    data[464:480] = bytes(16)
    header = [0x7009, 0x313] + [0] * 23
    header[9:11] = [1, 1120]
    header[15:17] = [5, 1132]
    header[19:21] = [1, 1140]
    struct.pack_into(">2H23I", data, 1024, *header)
    struct.pack_into(">3I", data, 1120, 0, 0, (2 << 26) | (2 << 21) | 0xFFFFF)
    data[1132:1137] = b"seed\0"
    fd = [0] * 19
    fd[3], fd[5] = 5, 1
    struct.pack_into(">10I2H7I", data, 1140, *fd)
    return bytes(data)


class OwnedSectionsTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        for name in ("src/example.c", "docs/example.md"):
            path = self.root / name
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text("fixture\n")
        self.config = self.root / "owned.json"

    def load(self, entries):
        self.config.write_text(json.dumps(entries))
        return load_owned_sections(self.config, self.root)

    def test_data_and_bss_have_distinct_load_semantics(self):
        data_entry = self.load([record()])[0]
        self.assertIn("AT(0x20)", linker_placements([data_entry]))
        bss_entry = self.load([record(True)])[0]
        self.assertIn("(NOLOAD)", linker_placements([bss_entry]))
        self.assertNotIn("AT(", linker_placements([bss_entry]))
        bss_entry["rom"] = 0x20
        with self.assertRaisesRegex(ValueError, "BSS must not claim"):
            self.load([bss_entry])

    @unittest.skipUnless(shutil.which("mips-linux-gnu-as") and shutil.which("mips-linux-gnu-ld"),
                         "MIPS binutils are needed for the linked placement regression")
    def test_word_aligned_table_keeps_its_declared_address(self):
        entry = record()
        entry.update(input_section=".rodata", vram=0x80002004,
                     symbols={"table_word": 0})
        self.load([entry])
        assembly = self.root / "table.s"
        assembly.write_text(
            '.section .rodata,"a",@progbits\n'
            '.balign 16\n.globl table_word\n.type table_word,@object\n'
            'table_word:\n.word 0x01020304\n.size table_word,4\n')
        obj, elf = self.root / "table.o", self.root / "table.elf"
        subprocess.run(["mips-linux-gnu-as", "-EB", "-32", "-o", str(obj),
                        str(assembly)], check=True, capture_output=True)
        # The assembler rounds the input section to its 16-byte alignment.
        # Only the declared word belongs to this source-owned range.
        from owned_sections import trim_owned_sections
        obj.write_bytes(trim_owned_sections(obj.read_bytes(), [entry]))
        script = self.root / "table.ld"
        script.write_text("SECTIONS { " + linker_placements([entry]) + " }\n")
        subprocess.run(["mips-linux-gnu-ld", "-EB", "-T", str(script),
                        "-o", str(elf), str(obj)], check=True, capture_output=True)
        target = bytearray(64)
        target[0x20:0x24] = b"\x01\x02\x03\x04"
        verify_owned_binary(elf, [entry], bytes(target))

    def test_rejects_wrong_encoded_address_and_overlapping_ranges(self):
        entry = record()
        entry["vram"] += 4
        with self.assertRaisesRegex(ValueError, "disagrees"):
            self.load([entry])
        first, second = record(), record(True)
        second["section"] = ".second"
        second["symbols"] = {"other_global": 0}
        with self.assertRaisesRegex(ValueError, "overlap"):
            self.load([first, second])

    def test_rejects_source_escape_and_invalid_sizes(self):
        for source in ("../example.c", "/src/example.c", "src\\example.c"):
            entry = record()
            entry["source"] = source
            with self.subTest(source=source), self.assertRaises(ValueError):
                self.load([entry])
        for size in (0, -1, True, "4"):
            entry = record()
            entry["size"] = size
            with self.subTest(size=size), self.assertRaises(ValueError):
                self.load([entry])

    def test_actual_object_and_linked_data_are_both_checked(self):
        entry = record()
        path = self.root / "fixture.elf"
        path.write_bytes(elf_fixture(entry, linked=False))
        verify_owned_binary(path, [entry], linked=False)
        path.write_bytes(elf_fixture(entry))
        target = bytearray(64)
        target[0x20:0x24] = b"\x01\x02\x03\x04"
        verify_owned_binary(path, [entry], bytes(target))
        target[0x22] ^= 1
        with self.assertRaisesRegex(ValueError, "data bytes differ"):
            verify_owned_binary(path, [entry], bytes(target))

    def test_compiler_readonly_tables_need_no_global_object_alias(self):
        entry = record()
        entry["input_section"] = ".rodata"
        entry["symbols"] = {}
        self.load([entry])
        path = self.root / "table.elf"
        contents = bytearray(elf_fixture(entry))
        # A compiler-local table symbol and an allocated, read-only section.
        contents[464 + 12] = 0x01
        struct.pack_into(">I", contents, 52 + 4 * 40 + 8, 2)
        path.write_bytes(contents)
        target = bytearray(64)
        target[0x20:0x24] = b"\x01\x02\x03\x04"
        verify_owned_binary(path, [entry], bytes(target))
        target[0x20] ^= 1
        with self.assertRaisesRegex(ValueError, "data bytes differ"):
            verify_owned_binary(path, [entry], bytes(target))
        # A real global may not be hidden by declaring an empty symbol set.
        contents[464 + 12] = 0x11
        path.write_bytes(contents)
        with self.assertRaisesRegex(ValueError, "source-owned definitions"):
            verify_owned_binary(path, [entry])
        contents[464 + 12] = 0x01
        struct.pack_into(">I", contents, 52 + 4 * 40 + 8, 3)
        path.write_bytes(contents)
        with self.assertRaisesRegex(ValueError, "read-only section is writable"):
            verify_owned_binary(path, [entry])
        for input_section in (".data", ".bss"):
            entry["input_section"] = input_section
            entry["rom"] = None if input_section == ".bss" else 0x20
            with self.subTest(input_section=input_section), self.assertRaisesRegex(
                    ValueError, "source definitions"):
                self.load([entry])

    def test_absolute_alias_cannot_hide_a_source_definition(self):
        entry = record()
        path = self.root / "fixture.elf"
        for absolute, wrong_type in ((True, False), (False, True)):
            path.write_bytes(elf_fixture(entry, absolute=absolute, wrong_type=wrong_type))
            with self.subTest(absolute=absolute), self.assertRaises(ValueError):
                verify_owned_binary(path, [entry])

    def test_private_data_requires_compiler_record_and_exact_offset(self):
        entry = record()
        entry["symbols"] = {}
        entry["static_symbols"] = {"seed": 0}
        self.load([entry])
        path = self.root / "private.o"
        path.write_bytes(private_elf_fixture(entry))
        verify_owned_binary(path, [entry], linked=False)
        for at, value in ((1124, 1), (1128, (4 << 26) | (2 << 21))):
            data = bytearray(private_elf_fixture(entry))
            struct.pack_into(">I", data, at, value)
            path.write_bytes(data)
            with self.assertRaisesRegex(ValueError, "source-private definitions"):
                verify_owned_binary(path, [entry], linked=False)
        for definitions in ({"seed": 4}, {"D_80002004": 0}, {"seed": True}):
            entry["static_symbols"] = definitions
            with self.assertRaises(ValueError):
                self.load([entry])

    def test_private_data_still_requires_exact_linked_payload(self):
        entry = record()
        entry["symbols"] = {}
        entry["static_symbols"] = {"seed": 0}
        path = self.root / "private.elf"
        data = bytearray(elf_fixture(entry))
        data[464:480] = bytes(16)
        path.write_bytes(data)
        target = bytearray(64)
        target[0x20:0x24] = b"\x01\x02\x03\x04"
        verify_owned_binary(path, [entry], bytes(target))
        target[0x20] ^= 1
        with self.assertRaisesRegex(ValueError, "data bytes differ"):
            verify_owned_binary(path, [entry], bytes(target))

    def test_bss_requires_a_noload_elf_section(self):
        entry = record(True)
        path = self.root / "fixture.elf"
        path.write_bytes(elf_fixture(entry))
        verify_owned_binary(path, [entry])
        path.write_bytes(elf_fixture(record()))
        with self.assertRaisesRegex(ValueError, "type/size"):
            verify_owned_binary(path, [entry])

    def test_data_cannot_overlap_function_or_change_object_ownership(self):
        entry = record()
        function = {"source": "src/example.c", "object": "build/us/example.o",
                    "vram": 0x80001000, "rom": 0x40, "size": 16}
        validate_function_ranges([entry], [function])
        for field, value in (("vram", entry["vram"]), ("rom", entry["rom"]),
                             ("object", "build/us/other.o")):
            changed = copy.deepcopy(function)
            changed[field] = value
            with self.subTest(field=field), self.assertRaises(ValueError):
                validate_function_ranges([entry], [changed])
