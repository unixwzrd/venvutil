"""Unit tests for setup/conda.sh Miniconda installer naming."""

from __future__ import annotations

import subprocess
import unittest
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parents[1]
CONDA_SH = PROJECT_ROOT / "setup" / "conda.sh"


def _resolve_name(fake_os: str, fake_arch: str) -> str:
    script = f"""
uname() {{
  case "$1" in
    -s) echo "{fake_os}" ;;
    -m) echo "{fake_arch}" ;;
    *) command uname "$@" ;;
  esac
}}
source "{CONDA_SH}"
UNAME_OS="$(uname -s)"
UNAME_ARCH="$(uname -m)"
printf '%s' "$(miniconda_installer_name)"
"""
    completed = subprocess.run(
        ["bash", "--noprofile", "--norc", "-c", script],
        cwd=str(PROJECT_ROOT),
        text=True,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        check=False,
    )
    if completed.returncode != 0:
        raise RuntimeError(
            "resolve_conda_installer_spec harness failed:\n"
            f"STDOUT:\n{completed.stdout}\nSTDERR:\n{completed.stderr}"
        )
    return completed.stdout


class CondaInstallerSpecTests(unittest.TestCase):
    def test_linux_arm64_maps_to_aarch64(self) -> None:
        name = _resolve_name(fake_os="Linux", fake_arch="arm64")
        self.assertEqual(name, "Miniconda3-latest-Linux-aarch64.sh")

    def test_linux_aarch64_stays_aarch64(self) -> None:
        name = _resolve_name(fake_os="Linux", fake_arch="aarch64")
        self.assertEqual(name, "Miniconda3-latest-Linux-aarch64.sh")

    def test_macos_arm64_uses_macosx_arm64(self) -> None:
        name = _resolve_name(fake_os="Darwin", fake_arch="arm64")
        self.assertEqual(name, "Miniconda3-latest-MacOSX-arm64.sh")

    def test_macos_aarch64_maps_to_arm64(self) -> None:
        name = _resolve_name(fake_os="Darwin", fake_arch="aarch64")
        self.assertEqual(name, "Miniconda3-latest-MacOSX-arm64.sh")


if __name__ == "__main__":
    unittest.main()
