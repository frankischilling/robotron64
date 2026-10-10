"""Retain one complete function from a verified contiguous C context.

This rebases ELF symbols and relocations, without changing any instruction.
Context functions and constants remain owned by their existing source objects.
The caller supplies the independently verified context layout and data hash.
"""

import hashlib
import struct


def retain_context(data, name, layout, readonly):
    if len(data) < 52 or data[:7] != b'\x7fELF\x01\x02\x01':
        raise ValueError('Expected ELF32 big-endian input')
    if struct.unpack_from('>HHI', data, 16) != (1, 8, 1):
        raise ValueError('Expected a relocatable MIPS object')
    offset = struct.unpack_from('>I', data, 32)[0]
    stride, count, names_index = struct.unpack_from('>HHH', data, 46)
    if stride != 40 or not count or offset + count*stride > len(data) or names_index >= count:
        raise ValueError('Invalid section table')
    sections = [struct.unpack_from('>10I', data, offset+i*stride) for i in range(count)]

    def payload(section):
        start, length = section[4:6]
        if start + length > len(data):
            raise ValueError('Truncated section')
        return data[start:start+length]

    def string(table, start):
        if start >= len(table) or b'\0' not in table[start:]:
            raise ValueError('Invalid string offset')
        return table[start:].split(b'\0', 1)[0].decode('ascii')

    names = payload(sections[names_index])
    indices = {string(names, s[0]): i for i, s in enumerate(sections)}
    if len(indices) != count or '.text' not in indices or '.rodata' not in indices:
        raise ValueError('Unexpected section set')
    text_index, readonly_index = indices['.text'], indices['.rodata']
    text, constants = sections[text_index], sections[readonly_index]
    if text[1:4] != (1, 6, 0) or text[5] % 4 or constants[1:4] != (1, 2, 0):
        raise ValueError('Unexpected code or constant section')
    original = payload(text)
    if constants[5] != readonly[0] or hashlib.sha256(payload(constants)).hexdigest() != readonly[1]:
        raise ValueError('Context constants changed')
    for label, i in indices.items():
        section = sections[i]
        if section[2] & 2 and label not in ('.text', '.rodata', '.reginfo') and section[5]:
            raise ValueError('Unexpected allocated context section')
    tables = [i for i, s in enumerate(sections) if s[1] == 2]
    if len(tables) != 1:
        raise ValueError('Expected one symbol table')
    symbols_index = tables[0]
    table = sections[symbols_index]
    if table[6] >= count or table[9] != 16 or table[5] % 16:
        raise ValueError('Malformed symbol table')
    strings = payload(sections[table[6]])
    symbols = [struct.unpack_from('>IIIBBH', payload(table), i) for i in range(0, table[5], 16)]
    functions = {}
    for i, symbol in enumerate(symbols):
        label, value, length, info, _, index = symbol
        if index == text_index and info & 15 == 2:
            label = string(strings, label)
            if label in functions or info >> 4 != 1:
                raise ValueError('Context functions must have unique global names')
            functions[label] = (i, value, length)
    if name not in layout or set(functions) != set(layout):
        raise ValueError('Unexpected function set')
    cursor = 0
    for label, (start, length) in sorted(layout.items(), key=lambda item: item[1][0]):
        if type(start) is not int or type(length) is not int or start != cursor or length <= 0 or length % 4:
            raise ValueError('Context layout must cover complete contiguous functions')
        if functions[label][1:] != (start, length):
            raise ValueError('Context function extent changed')
        cursor += length
    if not 0 <= len(original)-cursor < 16 or any(original[cursor:]):
        raise ValueError('Unowned live text or excessive alignment padding')
    retained_index, start, length = functions[name]
    end = start + length
    context_indices = {index for label, (index, _, _) in functions.items() if label != name}
    result = bytearray(data)
    result[text[4]:text[4]+text[5]] = original[start:end] + bytes(text[5]-length)
    struct.pack_into('>I', result, offset+text_index*stride+20, length)
    result[constants[4]:constants[4]+constants[5]] = bytes(constants[5])
    struct.pack_into('>I', result, offset+readonly_index*stride+20, 0)
    for i, symbol in enumerate(symbols):
        label, value, span, info, other, index = symbol
        if index == readonly_index:
            value, span, index = 0, 0, 0
        elif index == text_index:
            if i in context_indices:
                value, span, index = 0, 0, 0
            elif info & 15 == 3 and value == 0:
                span = length if span else 0
            elif start <= value and value+span <= end:
                value -= start
            else:
                raise ValueError('Symbol crosses the retained function boundary')
        struct.pack_into('>IIIBBH', result, table[4]+i*16, label, value, span, info, other, index)
    for i, section in enumerate(sections):
        if section[1] not in (4, 9):
            continue
        if section[1] != 9 or section[6] != symbols_index or section[5] % 8:
            raise ValueError('Unsupported relocation table')
        kept = bytearray()
        for position in range(section[5] // 8):
            place, info = struct.unpack_from('>II', payload(section), position*8)
            target_index, kind = info >> 8, info & 255
            if target_index >= len(symbols) or place % 4:
                raise ValueError('Invalid relocation')
            if section[7] == readonly_index:
                raise ValueError('Context constants must have no relocations')
            if section[7] != text_index:
                if symbols[target_index][5] in (text_index, readonly_index):
                    raise ValueError('Unexpected context reference')
                kept += struct.pack('>II', place, info)
                continue
            if place+4 > cursor:
                raise ValueError('Relocation lies outside complete function text')
            if not start <= place < end:
                continue
            target = symbols[target_index]
            if target[5] == readonly_index:
                raise ValueError('Retained function references context constants')
            if target[5] == text_index:
                if target_index not in context_indices or kind != 4:
                    raise ValueError('Unsupported reference into partitioned text')
                instruction = struct.unpack_from('>I', original, place)[0]
                if instruction >> 26 not in (2, 3) or instruction & 0x03FFFFFF:
                    raise ValueError('Context call has a nonzero addend')
            kept += struct.pack('>II', place-start, info)
        result[section[4]:section[4]+section[5]] = kept + bytes(section[5]-len(kept))
        struct.pack_into('>I', result, offset+i*stride+20, len(kept))
    return bytes(result)
