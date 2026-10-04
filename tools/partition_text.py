"""Retain a complete function compiled beside an already owned context function.

IDO uses the visible decoder body when deciding which static variables a call
can change. Its context function is built separately at the retail address.
This operation rebases ELF metadata and relocations, never MIPS instructions.
Only a context function at offset zero is supported, so its call addend stays
zero when its definition becomes an unresolved reference.
"""

import struct


def retain_function(data, name, context, size):
    if len(data) < 52 or data[:7] != b"\x7fELF\x01\x02\x01":
        raise ValueError("Expected ELF32 big-endian input")
    if struct.unpack_from(">HHI", data, 16) != (1, 8, 1):
        raise ValueError("Expected a relocatable MIPS object")
    offset = struct.unpack_from(">I", data, 32)[0]
    stride, count, names_index = struct.unpack_from(">HHH", data, 46)
    if stride != 40 or not count or offset + count * stride > len(data) or names_index >= count:
        raise ValueError("Invalid section table")
    sections = [struct.unpack_from(">10I", data, offset + i * stride) for i in range(count)]

    def payload(section):
        start, length = section[4:6]
        if start + length > len(data):
            raise ValueError("Truncated section")
        return data[start:start + length]

    def string(table, start):
        if start >= len(table) or b"\0" not in table[start:]:
            raise ValueError("Invalid string offset")
        return table[start:].split(b"\0", 1)[0].decode("ascii")

    names = payload(sections[names_index])
    text_indices = [i for i, s in enumerate(sections) if string(names, s[0]) == ".text"]
    if len(text_indices) != 1:
        raise ValueError("Expected one text section")
    text_index = text_indices[0]
    text = sections[text_index]
    if text[1] != 1 or text[2] != 6 or text[3] or text[5] % 4:
        raise ValueError("Unexpected text layout")
    original = payload(text)
    tables = [i for i, s in enumerate(sections) if s[1] == 2]
    if len(tables) != 1:
        raise ValueError("Expected one symbol table")
    symbols_index = tables[0]
    table = sections[symbols_index]
    if table[6] >= count or table[9] != 16 or table[5] % 16:
        raise ValueError("Malformed symbol table")
    strings = payload(sections[table[6]])
    symbols = [struct.unpack_from(">IIIBBH", payload(table), i) for i in range(0, table[5], 16)]
    functions = {}
    for i, symbol in enumerate(symbols):
        label, value, length, info, _, index = symbol
        if index == text_index and info & 15 == 2:
            label = string(strings, label)
            if label in functions or not length or value % 4 or length % 4 or value + length > len(original):
                raise ValueError("Invalid function extent")
            functions[label] = (i, value, length)
    if set(functions) != {name, context} or name == context:
        raise ValueError("Unexpected function set")
    _, start, length = functions[name]
    context_index, context_start, context_length = functions[context]
    if context_start or start != context_length or context_start + context_length > start:
        raise ValueError("Context must be the complete prefix at offset zero")
    if not 0 <= len(original) - start - length < 16 or any(original[start + length:]):
        raise ValueError("Unowned live text or excessive alignment padding")
    if type(size) is not int or size % 4 or not length <= size < length + 16 or size > len(original):
        raise ValueError("Invalid retained size or zero padding")

    result = bytearray(data)
    result[text[4]:text[4] + text[5]] = original[start:start + length] + bytes(text[5] - length)
    struct.pack_into(">I", result, offset + text_index * stride + 20, size)
    for i, symbol in enumerate(symbols):
        label, value, span, info, other, index = symbol
        if index != text_index:
            continue
        if i == context_index:
            if info >> 4 != 1:
                raise ValueError("Context reference must be global")
            value, span, index = 0, 0, 0
        elif info & 15 == 3:
            if value:
                raise ValueError("Unexpected text section symbol")
            span = size if span else 0
        elif start <= value and value + span <= start + length:
            value -= start
        else:
            raise ValueError("Symbol crosses the retained function boundary")
        struct.pack_into(">IIIBBH", result, table[4] + i * 16, label, value, span, info, other, index)

    for i, section in enumerate(sections):
        if section[1] not in (4, 9) or section[7] != text_index:
            continue
        if section[1] != 9 or section[6] != symbols_index or section[5] % 8:
            raise ValueError("Unsupported text relocation table")
        kept = bytearray()
        for position in range(0, section[5], 8):
            place, info = struct.unpack_from(">II", payload(section), position)
            symbol_index, kind = info >> 8, info & 255
            if symbol_index >= len(symbols) or place % 4 or place + 4 > start + length:
                raise ValueError("Relocation lies outside complete function text")
            if place < start:
                if place + 4 > start:
                    raise ValueError("Relocation crosses a function boundary")
                continue
            target = symbols[symbol_index]
            if target[5] == text_index:
                if symbol_index != context_index or kind != 4:
                    raise ValueError("Unsupported reference into partitioned text")
                instruction = struct.unpack_from(">I", original, place)[0]
                if instruction >> 26 not in (2, 3) or instruction & 0x03FFFFFF:
                    raise ValueError("Context call has a nonzero addend")
            kept += struct.pack(">II", place - start, info)
        result[section[4]:section[4] + section[5]] = kept + bytes(section[5] - len(kept))
        struct.pack_into(">I", result, offset + i * stride + 20, len(kept))
    return bytes(result)
