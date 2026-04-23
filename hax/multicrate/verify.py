#!/usr/bin/env python3
"""
Run `cargo hax into lean` for this workspace, then apply each crate's
`proofs/lean/changes.md` to the freshly extracted `proofs/lean/extraction/<crate>.lean`.

`changes.md` format (repeatable blocks):

  <!-- insert after line 7 -->
  import foo
  import bar

Line numbers are 1-based. Directives are applied in file order; each
`<!-- insert after line N -->` refers to the current file *after* all
previous blocks in the same `changes.md` have been applied (cumulative
line numbers).
"""

from __future__ import annotations

import re
import subprocess
import sys
from pathlib import Path

DIRECTIVE_RE = re.compile(
    r"<!--\s*insert\s+after\s+line\s+(\d+)\s*-->",
    re.IGNORECASE,
)


def multicrate_root() -> Path:
    return Path(__file__).resolve().parent


def discover_changes_files(root: Path) -> list[Path]:
    out: list[Path] = []
    for child in sorted(root.iterdir()):
        if not child.is_dir() or child.name.startswith("."):
            continue
        p = child / "proofs" / "lean" / "changes.md"
        if p.is_file():
            out.append(p)
    return out


def parse_changes_md(text: str) -> list[tuple[int, list[str]]]:
    lines = text.splitlines()
    blocks: list[tuple[int, list[str]]] = []
    i = 0
    while i < len(lines):
        m = DIRECTIVE_RE.match(lines[i].strip())
        if not m:
            i += 1
            continue
        after_line = int(m.group(1))
        i += 1
        content: list[str] = []
        while i < len(lines) and not DIRECTIVE_RE.match(lines[i].strip()):
            content.append(lines[i])
            i += 1
        while content and content[-1] == "":
            content.pop()
        blocks.append((after_line, content))
    return blocks


def apply_insert_after_blocks(
    original_lines: list[str], blocks: list[tuple[int, list[str]]]
) -> list[str]:
    """Apply each (after_line, content) in order; `after_line` is 1-based and
    interpreted against the file state after prior inserts."""
    if not blocks:
        return original_lines

    lines = list(original_lines)
    for block_idx, (after_line, content) in enumerate(blocks, start=1):
        if after_line < 0:
            raise ValueError(f"block {block_idx}: invalid line number {after_line}")
        if after_line > len(lines):
            raise ValueError(
                f"block {block_idx}: insert after line {after_line} but file has "
                f"only {len(lines)} line(s)"
            )
        # After line N (1-based): keep lines[0:N], insert, then rest (index N onward).
        lines = lines[:after_line] + content + lines[after_line:]
    return lines


def target_lean_for_crate(crate_dir: Path) -> Path:
    return crate_dir / "proofs" / "lean" / "extraction" / f"{crate_dir.name}.lean"


def main() -> int:
    root = multicrate_root()
    try:
        subprocess.run(
            ["cargo", "hax", "into", "lean"],
            cwd=root,
            check=True,
        )
    except FileNotFoundError:
        print("error: `cargo` not found on PATH", file=sys.stderr)
        return 1
    except subprocess.CalledProcessError as e:
        return e.returncode

    for changes_path in discover_changes_files(root):
        crate_dir = changes_path.parent.parent.parent
        text = changes_path.read_text(encoding="utf-8")
        blocks = parse_changes_md(text)
        if not blocks:
            continue
        lean_path = target_lean_for_crate(crate_dir)
        if not lean_path.is_file():
            print(
                f"error: {changes_path} has directives but {lean_path} is missing",
                file=sys.stderr,
            )
            return 1
        orig_lines = lean_path.read_text(encoding="utf-8").splitlines()
        try:
            new_lines = apply_insert_after_blocks(orig_lines, blocks)
        except ValueError as e:
            print(f"error applying {changes_path}: {e}", file=sys.stderr)
            return 1
        lean_path.write_text("\n".join(new_lines) + "\n", encoding="utf-8")
        print(f"patched {lean_path.relative_to(root)}")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
