from copy import deepcopy
from pathlib import Path
import sys
import unittest
from unittest.mock import patch

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "tools"))
from compare_data import data_linker_script, data_only_sources, verify_data_sections
from audit_publication import check_data_report


class DataComparisonTests(unittest.TestCase):
    def setUp(self):
        self.record = {"source": "src/sdk/example.c", "input_section": ".data",
                       "section": ".example_data", "size": 80}
        self.groups = {self.record["source"]: [self.record]}
        self.profile = {"version": "5.3", "flags": []}
        self.identity = {"version": "5.3", "compiler_sha256": "example"}
        self.report = {"matches": True, "blocks": {self.record["source"]: {
            "source": self.record["source"], "matches": True,
            "sections": [{"ownership": self.record, "bytes_sha256": "example"}],
            "compiler_profile": self.profile, "toolchain_identity": self.identity,
            "inputs_sha256": {},
        }}}

    def check(self, report):
        with patch("audit_publication.profile_for_source", return_value=self.profile), \
             patch("audit_publication.installed_identity", return_value=self.identity), \
             patch("audit_publication.data_input_hashes", return_value={}), \
             patch("audit_publication.check_inputs") as inputs:
            check_data_report(Path("."), report, self.groups)
            inputs.assert_called_once()

    def test_function_sources_use_their_complete_runtime_proofs(self):
        functions = [{"source": self.record["source"]}]
        self.assertEqual(data_only_sources(functions, [self.record]), {})
        self.assertEqual(data_only_sources([], [self.record]), self.groups)

    def test_empty_text_and_complete_owned_sections_are_allowed(self):
        sections = {".text": {"size": 0, "flags": 6}, ".data": {"size": 80, "flags": 3},
                    ".reginfo": {"size": 24, "flags": 2}}
        verify_data_sections(sections, {}, [self.record])

    def test_executable_content_is_rejected_even_if_zero(self):
        with self.assertRaisesRegex(ValueError, "unowned allocated|executable"):
            verify_data_sections({".text": {"size": 4, "flags": 6}}, {}, [self.record])

    def test_adjacent_sections_keep_explicit_placement_without_abi_orphans(self):
        records = [{"input_section": ".rodata", "section": ".offsets",
                    "vram": 0x80001000, "rom": 0x2000},
                   {"input_section": ".data", "section": ".jumps",
                    "vram": 0x80001020, "rom": 0x2020}]
        script = data_linker_script(set(), {}, records)
        self.assertIn(".offsets 0x80001000 : AT(0x2000)", script)
        self.assertIn(".jumps 0x80001020 : AT(0x2020)", script)
        self.assertIn("/DISCARD/ : { *(.reginfo .MIPS.abiflags) }", script)
        self.assertNotIn("*(.text)", script)

    def test_bss_only_unit_is_allowed_without_executable_content(self):
        record = {"input_section": ".bss", "size": 4528}
        verify_data_sections({".bss": {"size": 4528, "flags": 3}}, {}, [record])

    def test_unowned_initialized_section_is_rejected(self):
        with self.assertRaisesRegex(ValueError, "unowned allocated"):
            verify_data_sections({".rodata": {"size": 4, "flags": 2}}, {}, [self.record])

    def test_zero_size_procedure_is_rejected(self):
        with self.assertRaisesRegex(ValueError, "procedure"):
            verify_data_sections({}, {"example": {"type": 2}}, [self.record])

    def test_complete_current_report_is_accepted(self):
        self.check(self.report)

    def test_missing_source_cannot_pass(self):
        report = deepcopy(self.report)
        report["blocks"] = {}
        with self.assertRaisesRegex(ValueError, "source inventory"):
            self.check(report)

    def test_reduced_data_extent_cannot_pass(self):
        report = deepcopy(self.report)
        report["blocks"][self.record["source"]]["sections"][0]["ownership"]["size"] = 40
        with self.assertRaisesRegex(ValueError, "section inventory"):
            self.check(report)

    def test_stale_compiler_cannot_pass(self):
        report = deepcopy(self.report)
        report["blocks"][self.record["source"]]["toolchain_identity"] = {}
        with self.assertRaisesRegex(ValueError, "compiler identity"):
            self.check(report)


if __name__ == "__main__":
    unittest.main()
