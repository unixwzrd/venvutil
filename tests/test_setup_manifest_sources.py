"""Installer manifest regression tests.

This prevents stale `setup/manifest.lst` entries from referencing files that don't exist
in the repository (which would cause `cp: cannot stat ...` during installation).
"""

from __future__ import annotations

import unittest
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parents[1]
MANIFEST = PROJECT_ROOT / "setup" / "manifest.lst"


class SetupManifestSourceTests(unittest.TestCase):
    def test_all_manifest_file_sources_exist(self) -> None:
        missing: list[str] = []

        text = MANIFEST.read_text(encoding="utf-8", errors="replace")
        for raw in text.splitlines():
            line = raw.strip()
            if not line or line.startswith("#"):
                continue

            parts = [p.strip() for p in raw.split("|")]
            if len(parts) < 4:
                continue

            asset_type, _destination, source, name = (
                parts[0],
                parts[1],
                parts[2],
                parts[3],
            )
            if asset_type != "f":
                continue

            src = (PROJECT_ROOT / source / name) if source else (PROJECT_ROOT / name)
            if not src.exists():
                missing.append(f"{src}  (from: {raw})")

        if missing:
            self.fail("Missing manifest file sources:\n" + "\n".join(missing))


if __name__ == "__main__":
    unittest.main()


