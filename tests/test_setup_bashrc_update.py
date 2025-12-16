"""Unit tests for setup/post-install.sh .bashrc updates."""

from __future__ import annotations

import os
import subprocess
import tempfile
import unittest
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parents[1]


class UpdateBashrcTests(unittest.TestCase):
    def test_update_bashrc_is_idempotent_and_adds_block(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_home:
            env = os.environ.copy()
            env["HOME"] = tmp_home
            env.pop("BASH_ENV", None)
            env.pop("ENV", None)

            bashrc = Path(tmp_home) / ".bashrc"
            bashrc.write_text("# existing\n", encoding="utf-8")

            script = f"""
source "{PROJECT_ROOT}/bin/shinclude/config_lib.sh"
source "{PROJECT_ROOT}/setup/core.sh"
source "{PROJECT_ROOT}/setup/post-install.sh"
__SETUP_BASE="{PROJECT_ROOT}"
__SETUP_NAME="setup.sh"
__SETUP_DIR="{PROJECT_ROOT}/setup"
VERBOSE=false
INSTALL_BASE="{tmp_home}/local/venvutil"
PKG_NAME="venvutil"
INSTALL_CONFIG="{tmp_home}/.venvutil"
mkdir -p "${{INSTALL_CONFIG}}"
update_bashrc
update_bashrc
"""
            completed = subprocess.run(
                ["bash", "--noprofile", "--norc", "-c", script],
                env=env,
                cwd=str(PROJECT_ROOT),
                text=True,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                check=False,
            )
            self.assertEqual(
                completed.returncode,
                0,
                msg=f"update_bashrc failed:\nSTDOUT:\n{completed.stdout}\nSTDERR:\n{completed.stderr}",
            )

            text = bashrc.read_text(encoding="utf-8", errors="replace")
            self.assertEqual(text.count("# VENVUTIL START"), 1)
            self.assertEqual(text.count("# VENVUTIL END"), 1)
            self.assertIn(f'export PATH="{tmp_home}/local/venvutil/bin:$PATH"', text)
            self.assertIn("source", text)
            self.assertIn("cact venvutil", text)

            # Backup should exist after at least one run.
            backups = list(Path(tmp_home).glob(".bashrc.*.bak"))
            self.assertGreaterEqual(len(backups), 1)


if __name__ == "__main__":
    unittest.main()
# EOF
