from pathlib import Path
import sys
import struct
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "tools"))
from compiler import compiler_command, normalize_mips3_o32, profile_for_source
from rom import ROOT


class CompilerTests(unittest.TestCase):
    @staticmethod
    def mips3_object(flags=0x20000000):
        data = bytearray(96)
        data[:7] = b"\x7fELF\x01\x02\x01"
        struct.pack_into(">HHI", data, 16, 1, 8, 1)
        struct.pack_into(">I", data, 36, flags)
        data[52:] = bytes(range(44))
        return bytes(data)

    def test_mips3_o32_correction_preserves_all_other_bytes(self):
        original = self.mips3_object(0x20000001)
        normalized = normalize_mips3_o32(original)
        self.assertEqual(struct.unpack_from(">I", normalized, 36)[0], 0x20001001)
        self.assertEqual(normalized[:36], original[:36])
        self.assertEqual(normalized[40:], original[40:])
        self.assertEqual(normalize_mips3_o32(normalized), normalized)

    def test_mips3_o32_rejects_conflicting_architecture_and_abi(self):
        for flags in (0x10000000, 0x30000000, 0x20002000, 0x20000020, 0x20000200):
            with self.subTest(flags=hex(flags)), self.assertRaises(ValueError):
                normalize_mips3_o32(self.mips3_object(flags))
        original = self.mips3_object()
        invalid = [original[:20], b"bad" + original[3:]]
        for offset, value in ((4, 2), (5, 1), (6, 0), (17, 2), (19, 62), (23, 0)):
            changed = bytearray(original)
            changed[offset] = value
            invalid.append(changed)
        for data in invalid:
            with self.subTest(data=bytes(data[:24])), self.assertRaises(ValueError):
                normalize_mips3_o32(data)

    def test_game_sources_keep_the_verified_default(self):
        profile = profile_for_source("src/game/game_memory.c")
        self.assertEqual(profile["version"], "5.3")
        self.assertEqual(profile["flags"],
                         ["-O2", "-G", "0", "-non_shared", "-mips1", "-32"])

    def test_sdk_override_is_limited_to_verified_sources(self):
        profile = profile_for_source("src/libultra/pi_read.c")
        self.assertEqual(profile["flags"],
                         ["-O1", "-G", "0", "-non_shared", "-mips2", "-32"])
        self.assertEqual(profile_for_source("src/libultra/new_candidate.c")["name"],
                         "game")

    def test_game_multiply_workaround_keeps_the_verified_mips1_profile(self):
        command = compiler_command("src/game/audio_pitch_scale.c", "out.o")
        self.assertIn("-O2", command)
        self.assertIn("-mips1", command)
        self.assertNotIn("-mips2", command)
        self.assertEqual(command.count("-Wab,-r4300_mul"), 1)
        self.assertNotIn("-Wab,-r4300_mul",
                         compiler_command("src/game/audio_rate_scale.c", "out.o"))

    def test_command_preserves_paths_as_separate_arguments(self):
        command = compiler_command("src/game/path with spaces.c", "out dir/file.o")
        self.assertEqual(command[0], str(ROOT / ".local/toolchain/5.3/cc"))
        self.assertEqual(command[-3:], ["-o", "out dir/file.o",
                                       "src/game/path with spaces.c"])

    def test_verified_multiply_workaround_reaches_the_assembler(self):
        for source, optimization in (("gu_sine_float", "-O2"),
                                     ("gu_cosine_float", "-O2"),
                                     ("audio_effect_modulation", "-O3")):
            with self.subTest(source=source):
                command = compiler_command(f"src/libultra/{source}.c", "out.o")
                self.assertIn(optimization, command)
                self.assertIn("-mips2", command)
                self.assertEqual(command.count("-Wab,-r4300_mul"), 1)
        for source in ("src/game/fixed_math.c", "src/libultra/pi_read.c"):
            self.assertNotIn("-Wab,-r4300_mul", compiler_command(source, "out.o"))

    def test_returned_flags_cannot_mutate_the_profile(self):
        profile_for_source("src/game/example.c")["flags"].clear()
        self.assertIn("-O2", profile_for_source("src/game/example.c")["flags"])

    def test_canonical_relative_and_absolute_sources_select_the_same_profile(self):
        expected = profile_for_source("src/libultra/pi_read.c")
        for source in ("./src/libultra/pi_read.c", ROOT / "src/libultra/pi_read.c",
                       "src/libultra/../libultra/pi_read.c"):
            with self.subTest(source=source):
                self.assertEqual(profile_for_source(source), expected)

    def test_rejects_an_alternate_compiler(self):
        with self.assertRaisesRegex(ValueError, "pinned executable"):
            compiler_command("src/libultra/pi_read.c", "output.o", ".local/toolchain/7.1/cc")
        self.assertEqual(compiler_command("src/libultra/pi_read.c", "output.o"),
                         compiler_command("src/libultra/pi_read.c", "output.o",
                                          ".local/toolchain/5.3/cc"))
