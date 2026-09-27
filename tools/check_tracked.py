"""Reject commercial input paths and generated binary files in Git."""

import subprocess
from pathlib import Path

paths = subprocess.check_output(["git", "ls-files", "-z"]).decode().split("\0")
for name in filter(None, paths):
    path = Path(name)
    if path.parts[0] in {"baseroms", "build", ".local"} or path.suffix.lower() in {
        ".n64", ".v64", ".z64", ".bin", ".o", ".elf", ".a",
    }:
        raise SystemExit(f"Generated or commercial binary path tracked: {name}")
    if path.is_file() and path.read_bytes()[:4].hex() in {"80371240", "37804012", "40123780"}:
        raise SystemExit(f"ROM signature in tracked file: {name}")
print("Tracked paths contain no ROM signatures or generated binaries")
