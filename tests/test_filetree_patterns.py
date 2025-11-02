"""Unit tests for bin.filetree pattern handling."""

from __future__ import annotations

import importlib.util
import io
import os
import tempfile
import types
import unittest
from pathlib import Path

PROJECT_ROOT = Path(__file__).resolve().parents[1]
FILETREE_PATH = PROJECT_ROOT / "bin" / "filetree.py"


def _load_filetree_module() -> types.ModuleType:
    spec = importlib.util.spec_from_file_location("filetree_module", FILETREE_PATH)
    if spec is None or spec.loader is None:
        raise RuntimeError("Unable to load filetree module specification")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


FILETREE = _load_filetree_module()


class PatternNormalizationTests(unittest.TestCase):
    """Validate include and exclude pattern normalization."""

    def test_collect_patterns_with_pipe_delimiters(self) -> None:
        tokens = FILETREE.collect_pattern_tokens(["src/|.*.py|.*.json"])
        self.assertEqual(tokens, ["src/", ".*.py", ".*.json"])

    def test_normalize_converts_regex_like_extensions(self) -> None:
        tokens = FILETREE.collect_pattern_tokens([".*.py"])
        normalized = FILETREE.normalize_patterns(tokens, treat_as_include=True)
        self.assertIn("*.py", normalized)
        self.assertIn("**/*.py", normalized)

    def test_normalize_accepts_escaped_regex_tokens(self) -> None:
        tokens = FILETREE.collect_pattern_tokens(["src/|.*\\.py|.*\\.json"])
        normalized = FILETREE.normalize_patterns(tokens, treat_as_include=True)
        self.assertIn("*.py", normalized)
        self.assertIn("*.json", normalized)

    def test_normalize_trims_trailing_slashes(self) -> None:
        normalized = FILETREE.normalize_patterns(["src/"], treat_as_include=True)
        self.assertIn("src", normalized)
        self.assertIn("**/src", normalized)

    def test_is_included_accepts_py_and_json_files(self) -> None:
        include_tokens = FILETREE.collect_pattern_tokens(["src/|.*.py|.*.json"])
        include_patterns = FILETREE.normalize_patterns(
            include_tokens,
            treat_as_include=True,
        )
        directory_allowlist = FILETREE.extract_directory_allowlist(include_tokens)
        directory_patterns = set(directory_allowlist)
        directory_patterns.update(f"**/{directory}" for directory in directory_allowlist)
        include_patterns = [
            pattern
            for pattern in include_patterns
            if pattern not in directory_patterns
        ]
        self.assertTrue(
            FILETREE.is_included("src/module.py", include_patterns, show_all=False)
        )
        self.assertTrue(
            FILETREE.is_included(
                "src/nested/config.json",
                include_patterns,
                show_all=False,
            )
        )
        self.assertFalse(
            FILETREE.is_included(
                "src/nested/config.txt",
                include_patterns,
                show_all=False,
            )
        )

    def test_is_ignored_filters_dot_git_directories(self) -> None:
        exclude_tokens = FILETREE.collect_pattern_tokens([".git/"])
        exclude_patterns = FILETREE.normalize_patterns(
            exclude_tokens,
            treat_as_include=False,
        )
        self.assertTrue(
            FILETREE.is_ignored(".git/config", exclude_patterns, show_all=False)
        )

    def test_extract_directory_allowlist_identifies_src(self) -> None:
        include_tokens = FILETREE.collect_pattern_tokens(["src/|.*.py|.*.json"])
        allowlist = FILETREE.extract_directory_allowlist(include_tokens)
        self.assertEqual(allowlist, ["src"])

    def test_should_descend_directory_respects_allowlist(self) -> None:
        allowlist = ["src"]
        self.assertTrue(
            FILETREE.should_descend_directory("src", allowlist, show_all=False)
        )
        self.assertTrue(
            FILETREE.should_descend_directory("src/nested", allowlist, show_all=False)
        )
        self.assertFalse(
            FILETREE.should_descend_directory("config", allowlist, show_all=False)
        )

    def test_is_path_within_allowlist_for_files(self) -> None:
        allowlist = ["src"]
        self.assertTrue(FILETREE.is_path_within_allowlist("src/module.py", allowlist))
        self.assertFalse(FILETREE.is_path_within_allowlist("setup.py", allowlist))

    def test_follow_links_traverses_symlink_directories(self) -> None:
        with tempfile.TemporaryDirectory() as tmp_dir:
            tmp_path = Path(tmp_dir)
            real_dir = tmp_path / "real"
            symlink_dir = tmp_path / ".linked"
            nested_file = real_dir / "module.py"

            real_dir.mkdir()
            nested_file.write_text("print('symlink test')", encoding="utf-8")
            os.symlink(real_dir, symlink_dir)

            include_tokens = FILETREE.collect_pattern_tokens([".linked/|.*.py"])
            include_patterns = FILETREE.normalize_patterns(include_tokens, treat_as_include=True)
            allowlist = FILETREE.extract_directory_allowlist(include_tokens)
            directory_patterns = set(allowlist)
            directory_patterns.update(f"**/{directory}" for directory in allowlist)
            include_patterns = [
                pattern for pattern in include_patterns if pattern not in directory_patterns
            ]

            tree = FILETREE.Tree("Root")
            result = FILETREE.add_items(
                str(tmp_path),
                tree,
                exclude_patterns=[],
                include_patterns=include_patterns,
                show_all=False,
                relative_path="",
                follow_links=True,
                directory_allowlist=allowlist,
            )

            self.assertTrue(result)
            buffer = io.StringIO()
            console = FILETREE.Console(record=True, force_terminal=False, file=buffer)
            console.print(tree)
            rendered = console.export_text()

            self.assertIn(".linked/", rendered)
            self.assertIn("module.py", rendered)


if __name__ == "__main__":
    unittest.main()
