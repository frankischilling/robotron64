"""Install pinned IDO static recompilers for Linux x86-64."""

import argparse
import hashlib
import io
import json
from functools import lru_cache
import platform
import tarfile
import urllib.request
from pathlib import Path, PurePosixPath

ROOT = Path(__file__).resolve().parents[1]
RELEASE = "v1.2"
ARCHIVES = {
    "5.3": "ab5c741561f80913d58c8b074771f23941a3edd312505a8ebed6d1dfeb65e506",
    "7.1": "0d411696e178fcca34c31c3bf02011b928d7fd9c1fa7f8bf45070e0781b58e15",
}


@lru_cache(maxsize=8)
def _verify_files(directory, files, observations):
    # File metadata is part of the cache key. A changed component is hashed
    # again before a later compile or progress check can use it.
    for name, expected in files:
        path = Path(directory) / name
        if hashlib.sha256(path.read_bytes()).hexdigest() != expected:
            raise ValueError(f"Pinned compiler component changed: {path}")


def installed_identity(version, root=ROOT):
    manifest = json.loads((root / "config/toolchain_files.json").read_text())[version]
    if manifest["archive_sha256"] != ARCHIVES[version]:
        raise ValueError(f"Compiler file manifest has the wrong archive: {version}")
    directory = root / ".local/toolchain" / version
    stamp = directory / ".archive-sha256"
    if not stamp.is_file() or stamp.read_text().strip() != ARCHIVES[version]:
        raise ValueError(f"Pinned compiler archive record missing: {version}")
    files = tuple(sorted(manifest["files_sha256"].items()))
    if "cc" not in dict(files):
        raise ValueError(f"Compiler file manifest omits cc: {version}")
    observations = []
    for name, expected in files:
        relative = PurePosixPath(name)
        if relative.is_absolute() or ".." in relative.parts or "\\" in name:
            raise ValueError(f"Invalid compiler component path: {name}")
        path = directory / name
        if not path.is_file():
            raise ValueError(f"Pinned compiler component missing: {path}")
        info = path.stat()
        observations.append((info.st_size, info.st_mtime_ns, info.st_ctime_ns,
                             info.st_dev, info.st_ino))
    _verify_files(str(directory.resolve()), files, tuple(observations))
    return {
        "version": version,
        "archive_sha256": ARCHIVES[version],
        "compiler_sha256": dict(files)["cc"],
        "toolchain_files_sha256": hashlib.sha256(
            json.dumps(dict(files), sort_keys=True).encode()).hexdigest(),
    }


def install(version):
    if platform.system() != "Linux" or platform.machine() != "x86_64":
        raise SystemExit("Use x86-64 Linux or WSL2 for the pinned compiler")
    dest = ROOT / ".local/toolchain" / version
    stamp = dest / ".archive-sha256"
    if stamp.exists() and stamp.read_text().strip() == ARCHIVES[version] and (dest / "cc").exists():
        installed_identity(version)
        return
    url = ("https://github.com/decompals/ido-static-recomp/releases/download/"
           f"{RELEASE}/ido-{version}-recomp-linux.tar.gz")
    print(f"Downloading {url}", flush=True)
    with urllib.request.urlopen(url, timeout=120) as response:
        data = response.read()
    if hashlib.sha256(data).hexdigest() != ARCHIVES[version]:
        raise ValueError("Compiler archive checksum mismatch")
    dest.mkdir(parents=True, exist_ok=True)
    with tarfile.open(fileobj=io.BytesIO(data), mode="r:gz") as archive:
        for member in archive.getmembers():
            path = (dest / member.name).resolve()
            if not path.is_relative_to(dest.resolve()) or not (member.isfile() or member.isdir()):
                raise ValueError(f"Unsupported archive member: {member.name}")
        archive.extractall(dest, filter="data")
    stamp.write_text(ARCHIVES[version] + "\n")
    installed_identity(version)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("versions", nargs="*", default=["5.3"], choices=tuple(ARCHIVES))
    for version in parser.parse_args().versions:
        install(version)
