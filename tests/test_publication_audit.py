from copy import deepcopy
from pathlib import Path
import sys
import tempfile
import unittest
from unittest.mock import patch

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "tools"))

from audit_publication import (check_inputs, check_progress, check_public_files,
                               check_report, current_comparisons, expected_progress, sha256)
from compare_startup import SymbolLayoutSnapshot


class PublicationAuditTests(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory()
        self.addCleanup(self.directory.cleanup)
        self.root = Path(self.directory.name)
        self.source = "src/game/example.c"
        self.files = {
            self.source: '#include "../../include/example.h"\nint example(void) { return 1; }\n',
            "include/example.h": '#include "nested.h"\n',
            "include/nested.h": "int example(void);\n",
            "docs/example.md": "Complete synthetic example.\n",
            "Makefile": "all:\n",
            "linker_scripts/us.ld": "SECTIONS {}\n",
            "config/target.json": "{}\n",
            "config/toolchain_files.json": "{}\n",
            "tools/compiler.py": "# synthetic compiler metadata\n",
            "tools/owned_sections.py": "# synthetic ownership metadata\n",
        }
        self.files.update({name: "[]\n" for name in SymbolLayoutSnapshot.files})
        for name, contents in self.files.items():
            path = self.root / name
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text(contents)
        self.function = {"name": "func_80001000", "source": self.source,
                         "evidence": "docs/example.md", "size": 12,
                         "vram": 0x80001000, "section_vram": 0x80001000}
        self.functions = [self.function]
        self.expected = {"example": (self.source, 0x80001000, 0x8000100C)}
        self.report = {"matches": True, "blocks": {"example": {
            "source": self.source, "matches": True, "different_words": [],
            "actual_size": 12, "expected_size": 12,
            "inputs_sha256": {name: sha256(self.root / name) for name in self.files},
        }}}

    def progress(self, functions):
        return {**expected_progress(functions, []), "functions": [
            {"name": item["name"], "bytes": item["size"], "language": item.get("language", "C")}
            for item in functions]}

    def test_current_manifest_replaces_fixed_checkpoint_counts(self):
        old = self.progress(self.functions)
        expanded = self.functions + [{**self.function, "name": "func_8000100C", "size": 20}]
        check_progress(self.progress(expanded), expanded, [])
        with self.assertRaisesRegex(ValueError, "current manifest"):
            check_progress(old, expanded, [])

    def test_equal_totals_cannot_hide_a_replaced_function(self):
        report = self.progress(self.functions)
        report["functions"][0]["name"] = "func_80001004"
        with self.assertRaisesRegex(ValueError, "inventory is stale"):
            check_progress(report, self.functions, [])

    def test_duplicate_progress_records_are_rejected(self):
        report = self.progress(self.functions)
        report["functions"].append(deepcopy(report["functions"][0]))
        with self.assertRaisesRegex(ValueError, "duplicate"):
            check_progress(report, self.functions, [])

    def test_new_source_must_have_its_own_complete_comparison(self):
        current = {**self.expected, "second": ("src/game/second.c", 0x8000100C, 0x80001020)}
        with self.assertRaisesRegex(ValueError, "source inventory is stale"):
            check_report(self.root, "runtime-comparison", self.report, current)

    def test_source_rename_cannot_reuse_an_old_report(self):
        report = deepcopy(self.report)
        report["blocks"]["example"]["source"] = "src/game/old.c"
        with self.assertRaisesRegex(ValueError, "source disagrees"):
            check_report(self.root, "runtime-comparison", report, self.expected)

    def test_transitive_header_change_invalidates_a_matching_report(self):
        check_report(self.root, "runtime-comparison", self.report, self.expected)
        (self.root / "include/nested.h").write_text("long example(void);\n")
        with self.assertRaisesRegex(ValueError, "Stale comparison input: include/nested.h"):
            check_report(self.root, "runtime-comparison", self.report, self.expected)

    def test_new_header_requires_current_input_metadata(self):
        (self.root / "include/new.h").write_text("int new_function(void);\n")
        with self.assertRaisesRegex(ValueError, "omits current source/header metadata"):
            check_report(self.root, "runtime-comparison", self.report, self.expected)

    def test_complete_function_extent_is_required(self):
        report = deepcopy(self.report)
        report["blocks"]["example"]["actual_size"] = 8
        report["blocks"]["example"]["expected_size"] = 8
        with self.assertRaisesRegex(ValueError, "Incomplete target extent"):
            check_report(self.root, "runtime-comparison", report, self.expected)

    def test_missing_public_source_and_nested_header_are_rejected(self):
        check_public_files(self.root, list(self.files), self.functions, [])
        for missing in (self.source, "include/nested.h", "docs/example.md"):
            with self.subTest(missing=missing), self.assertRaisesRegex(ValueError, "omits current source"):
                check_public_files(self.root, [name for name in self.files if name != missing], self.functions, [])

    def test_runtime_inventory_cannot_refer_to_an_excluded_source(self):
        with patch("audit_publication.MATCHING_BLOCKS", (("old", "src/game/old.c", 0x80001000, 0x8000100C),)):
            with self.assertRaisesRegex(ValueError, "stale source metadata"):
                current_comparisons(self.functions)

    def test_verified_zero_alignment_is_separate_from_live_function_bytes(self):
        from compare_assembly import verify_text_coverage
        payload = bytes.fromhex("2402000103e000080000000000000000")
        self.assertEqual(verify_text_coverage(payload, self.functions), 4)
        self.assertEqual(expected_progress(self.functions, [])["matched_c_bytes"], 12)
        with self.assertRaisesRegex(ValueError, "unowned nonzero"):
            verify_text_coverage(payload[:-1] + b"\x01", self.functions)

    def test_startup_comparison_retains_its_verified_alignment_extent(self):
        block = ("startup", self.source, 0x80001000, 0x80001010)
        with patch("audit_publication.MATCHING_BLOCKS", ()), patch("audit_publication.STARTUP_BLOCKS", (block,)):
            families, _ = current_comparisons(self.functions)
        self.assertEqual(families["startup-comparison"]["startup"], block[1:])
        overlapping = self.functions + [{**self.function, "source": "src/game/next.c",
                                         "vram": 0x8000100C, "section_vram": 0x8000100C}]
        with patch("audit_publication.MATCHING_BLOCKS", ()), patch("audit_publication.STARTUP_BLOCKS", (block,)):
            with self.assertRaisesRegex(ValueError, "overlaps another source"):
                current_comparisons(overlapping)

    def test_input_path_cannot_escape_the_checkpoint(self):
        with self.assertRaisesRegex(ValueError, "project-relative"):
            check_inputs(self.root, {"../outside.c": "0" * 64}, {"../outside.c"})


if __name__ == "__main__":
    unittest.main()
