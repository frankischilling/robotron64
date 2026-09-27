from pathlib import Path
import shutil
import sys
import tempfile
import unittest

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "tools"))
from provenance import object_record, record, verify_record


class ProvenanceTests(unittest.TestCase):
    def setUp(self):
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

    def test_rejects_wrong_existing_source(self):
        (self.root / "other.c").write_text("void unrelated(void) {}\n")
        with self.assertRaisesRegex(ValueError, "Compiled source"):
            self.verify(source="other.c")

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
