"""Unit tests for setup/post-install.sh login-shell updates (.bash_profile/.profile)."""

from __future__ import annotations

import os
import subprocess
import tempfile
import unittest
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parents[1]


class UpdateBashLoginFileTests(unittest.TestCase):
    def test_update_bash_login_file_updates_profile_and_is_idempotent(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_home:
            env = os.environ.copy()
            env["HOME"] = tmp_home
            env.pop("BASH_ENV", None)
            env.pop("ENV", None)

            # Simulate the common macOS case where conda init wrote ~/.bash_profile already.
            bash_profile = Path(tmp_home) / ".bash_profile"
            bash_profile.write_text("# existing profile\n", encoding="utf-8")

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
update_bash_login_file
update_bash_login_file
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
                msg=f"update_bash_login_file failed:\nSTDOUT:\n{completed.stdout}\nSTDERR:\n{completed.stderr}",
            )

            text = bash_profile.read_text(encoding="utf-8", errors="replace")
            self.assertEqual(text.count("# VENVUTIL LOGIN START"), 1)
            self.assertEqual(text.count("# VENVUTIL LOGIN END"), 1)
            # Must not unconditionally source .bashrc; should be guarded by BASH_VERSION and interactive shell.
            self.assertIn('if [ -n "${BASH_VERSION:-}" ]; then', text)
            self.assertIn('case "$-" in', text)
            self.assertIn('[ -f "$HOME/.bashrc" ] && . "$HOME/.bashrc"', text)

            backups = list(Path(tmp_home).glob(".bash_profile.*.bak"))
            self.assertGreaterEqual(len(backups), 1)


if __name__ == "__main__":
    unittest.main()


