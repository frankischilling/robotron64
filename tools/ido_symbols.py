"""Read private function and data definitions from IDO's ECOFF debug records.

IDO retains these names in .mdebug even when ELF .symtab contains only a
section symbol. No object bytes or source linkage are changed by this reader.
The HDRR/FDR/SYMR layouts were checked against ZeldaRET's CC0
tools/ido_block_numbers.py and the ECOFF definitions cited in
docs/ido-static-functions.md.
"""

from pathlib import Path
import struct

def _parse_local_symbols(data, debug_offset, debug_size, text_size=None, section_sizes=None):
    end = debug_offset + debug_size
    if debug_offset < 0 or debug_size < 96 or end > len(data):
        raise ValueError("Truncated IDO debug header")
    header = struct.unpack_from(">2H23I", data, debug_offset)
    if header[0] != 0x7009:
        raise ValueError("Unsupported IDO debug magic")

    def table(count, offset, stride, label):
        length = count * stride
        if count and (offset < debug_offset + 96 or offset + length > end):
            raise ValueError(f"Invalid IDO {label} table extent")
        return offset, count

    symbols_at, symbol_count = table(header[9], header[10], 12, "symbol")
    aux_at, aux_count = table(header[13], header[14], 4, "auxiliary")
    strings_at, string_count = table(header[15], header[16], 1, "string")
    files_at, file_count = table(header[19], header[20], 72, "file descriptor")

    def symbol(index):
        if not 0 <= index < symbol_count:
            raise ValueError("Invalid IDO symbol index")
        return struct.unpack_from(">3I", data, symbols_at + 12 * index)

    def name(iss_base, string_size, offset):
        if not 0 <= offset < string_size:
            raise ValueError("Invalid IDO procedure name offset")
        start = strings_at + iss_base + offset
        terminator = data.find(b"\0", start, strings_at + iss_base + string_size)
        if terminator < 0:
            raise ValueError("Unterminated IDO procedure name")
        try:
            value = data[start:terminator].decode("ascii")
        except UnicodeDecodeError as error:
            raise ValueError("Invalid IDO procedure name") from error
        if not value:
            raise ValueError("Empty IDO procedure name")
        return value

    functions = {}
    variables = {}
    ranges = []
    for file_index in range(file_count):
        fd = struct.unpack_from(">10I2H7I", data, files_at + 72 * file_index)
        iss_base, string_size, sym_base, sym_size = fd[2:6]
        aux_base, aux_size = fd[12:14]
        if (iss_base + string_size > string_count or sym_base + sym_size > symbol_count
                or aux_base + aux_size > aux_count):
            raise ValueError("IDO file descriptor leaves its tables")
        for index in range(sym_size):
            iss, address, flags = symbol(sym_base + index)
            if flags >> 26 == 2 and section_sizes is not None:
                # stStatic: only allocated data classes participate in ownership.
                section = {2: ".data", 3: ".bss", 15: ".rodata"}.get((flags >> 21) & 31)
                if section is None:
                    continue
                if flags & (1 << 20) or address >= section_sizes.get(section, 0):
                    raise ValueError("Static data leaves its section")
                variable = name(iss_base, string_size, iss)
                if variable in variables:
                    raise ValueError("Ambiguous static data name")
                variables[variable] = (section, address)
                continue
            # stStaticProc / scText. Other debug entries are not functions.
            if flags >> 26 != 14 or text_size is None:
                continue
            if (flags >> 21) & 31 != 1 or flags & (1 << 20):
                raise ValueError("Invalid static procedure storage class")
            aux_index = flags & 0xFFFFF
            if aux_index >= aux_size:
                raise ValueError("Invalid static procedure auxiliary index")
            end_index = struct.unpack_from(
                ">I", data, aux_at + 4 * (aux_base + aux_index))[0] - 1
            if not index < end_index < sym_size:
                raise ValueError("Invalid static procedure end index")
            end_iss, size, end_flags = symbol(sym_base + end_index)
            if (end_flags >> 26 != 8 or (end_flags >> 21) & 31 != 1
                    or end_flags & (1 << 20) or end_flags & 0xFFFFF != index):
                raise ValueError("Static procedure end does not point to its start")
            procedure = name(iss_base, string_size, iss)
            if name(iss_base, string_size, end_iss) != procedure:
                raise ValueError("Static procedure end name disagrees")
            if size <= 0 or address % 4 or size % 4 or address + size > text_size:
                raise ValueError("Static procedure leaves its text section")
            if procedure in functions:
                raise ValueError("Ambiguous static procedure name")
            if any(address < previous_end and previous_start < address + size
                   for previous_start, previous_end in ranges):
                raise ValueError("Static procedure ranges overlap")
            functions[procedure] = (address, size)
            ranges.append((address, address + size))
    return functions, variables


def parse_local_functions(data, debug_offset, debug_size, text_size):
    """Return {name: (text_offset, size)} using paired static-procedure records."""
    return _parse_local_symbols(data, debug_offset, debug_size, text_size=text_size)[0]


def parse_local_data(data, debug_offset, debug_size, section_sizes):
    """Return {name: (input_section, offset)} for allocated static variables."""
    return _parse_local_symbols(data, debug_offset, debug_size, section_sizes=section_sizes)[1]


def _object_debug(path):
    # Kept local because owned_sections uses this reader when checking private data.
    from owned_sections import elf_sections_and_symbols

    path = Path(path)
    sections, _ = elf_sections_and_symbols(path)
    data = path.read_bytes()
    if struct.unpack_from(">H", data, 16)[0] != 1:
        raise ValueError("IDO local symbol verification requires a relocatable object")
    return data, sections, sections.get(".mdebug")


def local_functions(path):
    """Read an unlinked ELF32 big-endian IDO object without changing it."""
    data, sections, debug = _object_debug(path)
    if debug is None:
        return {}
    text = sections.get(".text")
    if text is None or text["type"] != 1 or text["address"] != 0:
        raise ValueError("Missing relocatable text for IDO procedures")
    return parse_local_functions(data, debug["offset"], debug["size"], text["size"])


def local_data(path):
    """Read private data names and section offsets from an unlinked IDO object."""
    data, sections, debug = _object_debug(path)
    if debug is None:
        return {}
    sizes = {}
    for name in (".data", ".bss", ".rodata"):
        section = sections.get(name)
        if section is not None:
            expected_type = 8 if name == ".bss" else 1
            if section["address"] != 0 or section["type"] != expected_type:
                raise ValueError("Invalid relocatable section for IDO static data")
            sizes[name] = section["size"]
    return parse_local_data(data, debug["offset"], debug["size"], sizes)
