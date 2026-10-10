from pathlib import Path
import json
import shutil
import sys
import tempfile
import unittest
from unittest.mock import patch

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "tools"))
from provenance import object_record, record, verify_record


class ProvenanceTests(unittest.TestCase):
    def setUp(self):
        self.identity = {"version": "5.3", "compiler_sha256": "synthetic compiler"}
        self.identity_patch = patch("provenance.installed_identity", return_value=self.identity)
        self.identity_patch.start()
        self.addCleanup(self.identity_patch.stop)
        directory = tempfile.TemporaryDirectory()
        self.addCleanup(directory.cleanup)
        self.root = Path(directory.name)
        (self.root / "source.c").write_text("void function(void) {}\n")
        (self.root / "types.h").write_text("typedef int Value;\n")
        (self.root / "compiled.o").write_bytes(b"synthetic object bytes")
        record("source.c", "compiled.o", ["types.h"], self.root)

    def verify(self, source="source.c", object_name="compiled.o"):
        verify_record(source, object_name, self.root)

    def test_accepts_current_source_headers_and_object(self):
        self.verify()

    def test_partition_helper_is_required_and_changes_invalidate_the_object(self):
        source = "src/game/audio/sequence_tick.c"
        helper = "tools/partition_text.py"
        for name in (source, helper):
            path = self.root / name
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text("synthetic input\n")
        record(source, "compiled.o", root=self.root)
        verify_record(source, "compiled.o", self.root)
        path = object_record(self.root / "compiled.o")
        metadata = json.loads(path.read_text())
        self.assertIn(helper, metadata["inputs"])
        del metadata["inputs"][helper]
        path.write_text(json.dumps(metadata))
        with self.assertRaisesRegex(ValueError, "omits local header.*partition_text.py"):
            verify_record(source, "compiled.o", self.root)
        record(source, "compiled.o", root=self.root)
        (self.root / helper).write_text("changed helper\n")
        with self.assertRaisesRegex(ValueError, "Build input changed.*partition_text.py"):
            verify_record(source, "compiled.o", self.root)

    def test_rejects_wrong_existing_source(self):
        (self.root / "other.c").write_text("void unrelated(void) {}\n")
        with self.assertRaisesRegex(ValueError, "Compiled source"):
            self.verify(source="other.c")

    def test_contiguous_context_helper_is_recorded_and_invalidates_the_object(self):
        source = "src/game/renderer_diagnostics/fatal_format.c"
        helper = "tools/partition_context.py"
        for name in (source, helper):
            path = self.root / name
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text("synthetic input\n")
        record(source, "compiled.o", root=self.root)
        verify_record(source, "compiled.o", self.root)
        metadata = json.loads(object_record(self.root / "compiled.o").read_text())
        self.assertIn(helper, metadata["inputs"])
        (self.root / helper).write_text("changed context partition helper\n")
        with self.assertRaisesRegex(ValueError, "Build input changed.*partition_context.py"):
            verify_record(source, "compiled.o", self.root)

    def test_rejects_changed_source_or_header(self):
        for filename in ("source.c", "types.h"):
            with self.subTest(filename=filename):
                path = self.root / filename
                original = path.read_bytes()
                path.write_bytes(original + b"/* changed */\n")
                with self.assertRaisesRegex(ValueError, "Build input changed"):
                    self.verify()
                path.write_bytes(original)

    def test_rejects_modified_object(self):
        (self.root / "compiled.o").write_bytes(b"changed object bytes")
        with self.assertRaisesRegex(ValueError, "Object changed"):
            self.verify()

    def test_rejects_missing_build_record(self):
        object_record(self.root / "compiled.o").unlink()
        with self.assertRaisesRegex(ValueError, "Missing build provenance"):
            self.verify()

    def test_rejects_record_copied_to_different_object(self):
        shutil.copyfile(self.root / "compiled.o", self.root / "other.o")
        shutil.copyfile(object_record(self.root / "compiled.o"),
                        object_record(self.root / "other.o"))
        with self.assertRaisesRegex(ValueError, "different object"):
            self.verify(object_name="other.o")

    def test_record_requires_transitive_local_headers(self):
        (self.root / "source.c").write_text('#include "types.h"\n')
        (self.root / "types.h").write_text('#include "nested.h"\n')
        (self.root / "nested.h").write_text('typedef int Value;\n')
        with self.assertRaisesRegex(ValueError, "omits local header.*nested.h"):
            record("source.c", "compiled.o", ["types.h"], self.root)
        record("source.c", "compiled.o", ["types.h", "nested.h"], self.root)
        self.verify()

    def test_verify_rejects_header_omitted_from_record(self):
        (self.root / "source.c").write_text('#include "types.h"\n')
        record("source.c", "compiled.o", ["types.h"], self.root)
        path = object_record(self.root / "compiled.o")
        metadata = json.loads(path.read_text())
        del metadata["inputs"]["types.h"]
        path.write_text(json.dumps(metadata))
        with self.assertRaisesRegex(ValueError, "omits local header.*types.h"):
            self.verify()

    def test_header_cycles_are_recorded_once(self):
        (self.root / "source.c").write_text('#include "types.h"\n')
        (self.root / "types.h").write_text('#include "nested.h"\n')
        (self.root / "nested.h").write_text('#include "types.h"\n')
        record("source.c", "compiled.o", ["types.h", "nested.h"], self.root)
        self.verify()

    def test_rejects_changed_or_missing_compiler_profile(self):
        path = object_record(self.root / "compiled.o")
        metadata = json.loads(path.read_text())
        metadata["compiler_profile"]["flags"][0] = "-O1"
        path.write_text(json.dumps(metadata))
        with self.assertRaisesRegex(ValueError, "Compiler profile changed"):
            self.verify()
        del metadata["compiler_profile"]
        path.write_text(json.dumps(metadata))
        with self.assertRaisesRegex(ValueError, "Compiler profile changed"):
            self.verify()

    def test_rejects_different_compiler_identity(self):
        self.identity["compiler_sha256"] = "a different synthetic compiler"
        with self.assertRaisesRegex(ValueError, "Compiler identity changed"):
            self.verify()
