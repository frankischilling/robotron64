import hashlib
import json
from pathlib import Path
import sys
import tempfile
import unittest
from unittest.mock import patch

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "tools"))
from toolchain import installed_identity, _verify_files


class ToolchainIdentityTests(unittest.TestCase):
    def setUp(self):
        self.directory = tempfile.TemporaryDirectory()
        self.addCleanup(self.directory.cleanup)
        self.root = Path(self.directory.name)
        (self.root / "config").mkdir()
        self.tools = self.root / ".local/toolchain/test"
        self.tools.mkdir(parents=True)
        archive = hashlib.sha256(b"synthetic archive").hexdigest()
        self.pin = patch.dict("toolchain.ARCHIVES", {"test": archive})
        self.pin.start()
        self.addCleanup(self.pin.stop)
        files = {}
        for name in ("cc", "cfe"):
            data = ("synthetic " + name).encode()
            (self.tools / name).write_bytes(data)
            files[name] = hashlib.sha256(data).hexdigest()
        self.manifest = {"test": {"archive_sha256": archive, "files_sha256": files}}
        (self.root / "config/toolchain_files.json").write_text(json.dumps(self.manifest))
        (self.tools / ".archive-sha256").write_text(archive + "\n")
        _verify_files.cache_clear()

    def test_records_the_verified_driver_and_all_toolchain_files(self):
        identity = installed_identity("test", self.root)
        self.assertEqual(identity["compiler_sha256"],
                         self.manifest["test"]["files_sha256"]["cc"])
        self.assertEqual(len(identity["toolchain_files_sha256"]), 64)

    def test_rejects_modified_components_even_after_a_cached_check(self):
        installed_identity("test", self.root)
        (self.tools / "cfe").write_bytes(b"replacement front end")
        with self.assertRaisesRegex(ValueError, "component changed"):
            installed_identity("test", self.root)

    def test_rejects_missing_components_and_archive_record(self):
        (self.tools / "cc").unlink()
        with self.assertRaisesRegex(ValueError, "component missing"):
            installed_identity("test", self.root)
        (self.tools / ".archive-sha256").write_text("different archive")
        with self.assertRaisesRegex(ValueError, "archive record missing"):
            installed_identity("test", self.root)
