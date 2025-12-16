"""Unit tests for setup.sh installer safety and re-entry regressions.

These tests intentionally avoid running the full `install` action (which downloads conda
and installs Python packages). Instead they validate:

- `initialization` resolves a sane default `INSTALL_BASE` from `setup/setup.cf`.
- `refresh` runs only once (regression test for accidental double `main "$@"` execution).

All execution is forced into temporary HOME and install base directories so no user state
is modified.
"""

from __future__ import annotations

import os
import subprocess
import tempfile
import unittest
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parents[1]
SETUP_SH = PROJECT_ROOT / "setup.sh"


class SetupInstallerSafetyTests(unittest.TestCase):
    def test_initialization_sets_default_install_base_from_setup_cf(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_home:
            env = os.environ.copy()
            env["HOME"] = tmp_home
            env["PAGER"] = "cat"
            env.pop("BASH_ENV", None)
            env.pop("ENV", None)
            env.pop("VENVUTIL_CONFIG", None)

            script = f"""
source "{PROJECT_ROOT}/bin/shinclude/config_lib.sh"
source "{PROJECT_ROOT}/setup/core.sh"
__SETUP_BASE="{PROJECT_ROOT}"
__SETUP_NAME="setup.sh"
__SETUP_DIR="{PROJECT_ROOT}/setup"
VERBOSE=false
INSTALL_BASE=""
ACTION="refresh"
initialization
printf '%s' "$INSTALL_BASE"
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
                msg=f"initialization failed:\nSTDOUT:\n{completed.stdout}\nSTDERR:\n{completed.stderr}",
            )

            expected = str(Path(tmp_home) / "local" / "venvutil")
            self.assertEqual(completed.stdout, expected)
            self.assertNotEqual(completed.stdout, "/")
            self.assertNotEqual(completed.stdout, "")

    def test_refresh_runs_once_and_installs_to_specified_base(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_home, tempfile.TemporaryDirectory() as tmp_install:
            env = os.environ.copy()
            env["HOME"] = tmp_home
            env["PAGER"] = "cat"
            env.pop("BASH_ENV", None)
            env.pop("ENV", None)
            env.pop("VENVUTIL_CONFIG", None)

            completed = subprocess.run(
                ["bash", "--noprofile", "--norc", str(SETUP_SH), "-d", tmp_install, "refresh"],
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
                msg=f"refresh failed:\nSTDOUT:\n{completed.stdout}\nSTDERR:\n{completed.stderr}",
            )

            # Basic artifact check: a known file from the manifest should exist in the install base.
            self.assertTrue((Path(tmp_install) / "bin" / "filetree.py").exists())
            # Regression check for stale manifest source paths (must be copied successfully).
            self.assertTrue((Path(tmp_install) / "manifest.lst").exists())
            self.assertTrue((Path(tmp_install) / "setup.cf").exists())
            self.assertTrue(
                (
                    Path(tmp_install)
                    / "docs"
                    / "shdoc"
                    / "bin"
                    / "shinclude"
                    / "functions"
                    / "load_config.md"
                ).exists()
            )

            # Regression check: refresh should only execute once (no accidental second main()).
            install_log = Path(tmp_home) / ".venvutil" / "install.log"
            self.assertTrue(install_log.exists(), msg=f"Expected install log at {install_log}")
            log_text = install_log.read_text(encoding="utf-8", errors="replace")
            self.assertEqual(log_text.count("Refreshing venvutil tools..."), 1)


if __name__ == "__main__":
    unittest.main()
