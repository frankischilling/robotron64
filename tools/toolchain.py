"""Install pinned IDO static recompilers for Linux x86-64."""

import argparse
import hashlib
import io
import platform
import tarfile
import urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
RELEASE = "v1.2"
ARCHIVES = {
    "5.3": "ab5c741561f80913d58c8b074771f23941a3edd312505a8ebed6d1dfeb65e506",
    "7.1": "0d411696e178fcca34c31c3bf02011b928d7fd9c1fa7f8bf45070e0781b58e15",
}


def install(version):
    if platform.system() != "Linux" or platform.machine() != "x86_64":
        raise SystemExit("Use x86-64 Linux or WSL2 for the pinned compiler")
    dest = ROOT / ".local/toolchain" / version
    stamp = dest / ".archive-sha256"
    if stamp.exists() and stamp.read_text().strip() == ARCHIVES[version] and (dest / "cc").exists():
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


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("versions", nargs="*", default=["5.3"], choices=tuple(ARCHIVES))
    for version in parser.parse_args().versions:
        install(version)
