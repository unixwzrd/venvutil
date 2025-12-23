"""Unit tests that ensure conda installer download failures are not swallowed."""

from __future__ import annotations

import subprocess
import unittest
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parents[1]
CONDA_SH = PROJECT_ROOT / "setup" / "conda.sh"


class CondaCurlFailureTests(unittest.TestCase):
    def test_get_conda_installer_fails_when_curl_fails(self) -> None:
        script = f"""
set -u
log_message() {{ :; }}
get_os_config() {{ UNAME_OS="Linux"; UNAME_ARCH="arm64"; }}
curl() {{ return 22; }}
INSTALL_CONFIG="/tmp/venvutil-test-install-config"
mkdir -p "${{INSTALL_CONFIG}}"
source "{CONDA_SH}"
get_os_config
if get_conda_installer >/dev/null 2>&1; then
  exit 1
fi
"""
        completed = subprocess.run(
            ["bash", "--noprofile", "--norc", "-c", script],
            cwd=str(PROJECT_ROOT),
            text=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            check=False,
        )
        self.assertEqual(
            completed.returncode,
            0,
            msg=f"Expected failure path when curl fails.\nSTDOUT:\n{completed.stdout}\nSTDERR:\n{completed.stderr}",
        )


if __name__ == "__main__":
    unittest.main()
