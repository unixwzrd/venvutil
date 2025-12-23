"""Unit tests for setup/core.sh get_os_config() raw uname capture."""

from __future__ import annotations

import subprocess
import unittest
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parents[1]
CORE_SH = PROJECT_ROOT / "setup" / "core.sh"


def _run_get_os_config(fake_os: str, fake_arch: str) -> tuple[str, str]:
    script = f"""
uname() {{
  case "$1" in
    -s) echo "{fake_os}" ;;
    -m) echo "{fake_arch}" ;;
    *) command uname "$@" ;;
  esac
}}
source "{CORE_SH}"
get_os_config
printf '%s|%s' "$UNAME_OS" "$UNAME_ARCH"
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
            "get_os_config test harness failed:\n"
            f"STDOUT:\n{completed.stdout}\nSTDERR:\n{completed.stderr}"
        )
    os_name, arch = completed.stdout.split("|", 1)
    return os_name, arch


class GetOsConfigTests(unittest.TestCase):
    def test_macos_arm64(self) -> None:
        os_name, arch = _run_get_os_config(fake_os="Darwin", fake_arch="arm64")
        self.assertEqual(os_name, "Darwin")
        self.assertEqual(arch, "arm64")

    def test_macos_x86_64(self) -> None:
        os_name, arch = _run_get_os_config(fake_os="Darwin", fake_arch="x86_64")
        self.assertEqual(os_name, "Darwin")
        self.assertEqual(arch, "x86_64")

    def test_linux_aarch64(self) -> None:
        os_name, arch = _run_get_os_config(fake_os="Linux", fake_arch="aarch64")
        self.assertEqual(os_name, "Linux")
        self.assertEqual(arch, "aarch64")

    def test_linux_arm64_is_raw(self) -> None:
        os_name, arch = _run_get_os_config(fake_os="Linux", fake_arch="arm64")
        self.assertEqual(os_name, "Linux")
        self.assertEqual(arch, "arm64")

    def test_linux_x86_64_is_raw(self) -> None:
        os_name, arch = _run_get_os_config(fake_os="Linux", fake_arch="x86_64")
        self.assertEqual(os_name, "Linux")
        self.assertEqual(arch, "x86_64")


if __name__ == "__main__":
    unittest.main()
