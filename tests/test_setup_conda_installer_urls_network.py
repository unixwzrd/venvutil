"""Optional network test: verify Miniconda installer URLs exist.

This test is skipped by default. Enable by setting:

    VENVUTIL_NETWORK_TESTS=1

It uses curl with -f so 404s fail the test without downloading the payload.
"""

from __future__ import annotations

import os
import shutil
import subprocess
import unittest


@unittest.skipUnless(
    os.environ.get("VENVUTIL_NETWORK_TESTS") == "1",
    "network tests disabled (set VENVUTIL_NETWORK_TESTS=1 to enable)",
)
@unittest.skipUnless(shutil.which("curl"), "curl not available")
class MinicondaInstallerUrlNetworkTests(unittest.TestCase):
    def test_miniconda_latest_urls_exist(self) -> None:
        combos = [
            ("Linux", "x86_64"),
            ("Linux", "aarch64"),
            ("MacOSX", "x86_64"),
            ("MacOSX", "arm64"),
        ]
        for os_name, arch in combos:
            url = f"https://repo.anaconda.com/miniconda/Miniconda3-latest-{os_name}-{arch}.sh"
            completed = subprocess.run(
                ["curl", "-fILsS", url],
                text=True,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                check=False,
            )
            self.assertEqual(
                completed.returncode,
                0,
                msg=f"URL not accessible: {url}\nSTDERR:\n{completed.stderr}\nSTDOUT:\n{completed.stdout}",
            )


if __name__ == "__main__":
    unittest.main()
