"""Remove verified trailing zero padding from an ELF32 big-endian section.

Used while reconstructing only part of an original compilation unit. No code,
relocations, or live data may be removed. The original compiler output is kept.
"""

import argparse
from pathlib import Path
import struct


def trim(data, name, size):
    if data[:6] != b'\x7fELF\x01\x02':
        raise ValueError('Expected ELF32 big-endian input')
    if len(data) < 52:
        raise ValueError('Truncated ELF header')
    offset = struct.unpack_from('>I', data, 32)[0]
    stride, count, names_index = struct.unpack_from('>HHH', data, 46)
    if stride != 40 or offset + count * stride > len(data) or names_index >= count:
        raise ValueError('Invalid section table')
    sections = [struct.unpack_from('>10I', data, offset + i * stride) for i in range(count)]
    names = sections[names_index]
    strings = data[names[4]:names[4] + names[5]]
    indices = [i for i, s in enumerate(sections)
               if strings[s[0]:].split(b'\0', 1)[0] == name.encode()]
    if len(indices) != 1:
        raise ValueError('Expected exactly one requested section')
    index = indices[0]
    section = sections[index]
    start, old_size = section[4:6]
    if section[1] not in (1, 8) or size < 0 or size > old_size:
        raise ValueError('Invalid section extent')
    if section[1] == 1 and start + old_size > len(data):
        raise ValueError('Invalid section extent')
    if old_size - size >= 16 or (section[1] == 1 and
                               any(data[start + size:start + old_size])):
        raise ValueError('Tail is not sub-16-byte zero alignment padding')
    result = bytearray(data)
    for s in sections:
        if s[1] in (4, 9) and s[7] == index:
            entry_size = 12 if s[1] == 4 else 8
            if s[5] % entry_size or s[4] + s[5] > len(data):
                raise ValueError('Malformed relocation section')
            for pos in range(s[4], s[4] + s[5], entry_size):
                if struct.unpack_from('>I', data, pos)[0] + 4 > size:
                    raise ValueError('Relocation touches removed padding')
        if s[1] == 2:
            if s[5] % 16 or s[4] + s[5] > len(data):
                raise ValueError('Malformed symbol table')
            for pos in range(s[4], s[4] + s[5], 16):
                _, value, length, info, _, shndx = struct.unpack_from('>IIIBBH', data, pos)
                if shndx == index and info & 15 == 3 and value == 0 and length == old_size:
                    struct.pack_into('>I', result, pos + 8, size)
                    continue
                if shndx == index and value + length > size:
                    raise ValueError('Symbol touches removed padding')
    struct.pack_into('>I', result, offset + index * stride + 20, size)
    return bytes(result)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('source', type=Path)
    parser.add_argument('output', type=Path)
    parser.add_argument('section')
    parser.add_argument('size', type=lambda text: int(text, 0))
    args = parser.parse_args()
    args.output.write_bytes(trim(args.source.read_bytes(), args.section, args.size))
