import hashlib
from pathlib import Path
import sys
import tempfile
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "tools"))

from compare_startup import comparison_input_hashes


class ComparisonInputTests(unittest.TestCase):
    def setUp(self):
        directory = tempfile.TemporaryDirectory()
        self.addCleanup(directory.cleanup)
        self.root = Path(directory.name)
        files = {
            "src/game/audio.c": '#include "forward.h"\nint function(void) { return 0; }\n',
            "src/game/forward.h": '#include "../../include/audio.h"\n',
            "include/audio.h": '#include "detail/voice.h"\n',
            "include/detail/voice.h": "typedef unsigned int VoiceWord;\n",
            "include/unrelated.h": "typedef int OtherWord;\n",
        }
        for filename in ("config/startup_symbols.ld", "config/runtime_symbols.ld",
                         "config/functions.json", "tools/compiler.py",
                         "config/toolchain_files.json", "config/owned_sections.json",
                         "tools/owned_sections.py"):
            files[filename] = "unchanged metadata\n"
        for filename, text in files.items():
            path = self.root / filename
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text(text)

    def test_forwarding_and_nested_headers_are_in_the_comparison_record(self):
        hashes = comparison_input_hashes("src/game/audio.c", self.root)
        for filename in ("src/game/forward.h", "include/audio.h",
                         "include/detail/voice.h", "include/unrelated.h"):
            self.assertEqual(hashes[filename], hashlib.sha256(
                (self.root / filename).read_bytes()).hexdigest())

    def test_changing_only_the_forwarding_header_invalidates_old_inputs(self):
        previous = comparison_input_hashes("src/game/audio.c", self.root)
        (self.root / "src/game/forward.h").write_text('#include "../../include/unrelated.h"\n')
        current = comparison_input_hashes("src/game/audio.c", self.root)
        self.assertNotEqual(previous["src/game/forward.h"], current["src/game/forward.h"])
        self.assertIn("include/detail/voice.h", previous)
        self.assertNotIn("include/detail/voice.h", current)

    def test_missing_transitive_header_cannot_produce_a_comparison_record(self):
        (self.root / "include/detail/voice.h").unlink()
        with self.assertRaises(ValueError):
            comparison_input_hashes("src/game/audio.c", self.root)


if __name__ == "__main__":
    unittest.main()
