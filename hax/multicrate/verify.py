#!/usr/bin/env python3
"""
For each crate directory under this workspace, run `cargo hax into lean`, then
ensure `proofs/lean/extraction/<crate>.lean` contains:

    import <crate>.interface

immediately after the `import Hax` line.
"""

from __future__ import annotations

import subprocess
import sys
from pathlib import Path


def multicrate_root() -> Path:
    return Path(__file__).resolve().parent


def discover_crate_dirs(root: Path) -> list[Path]:
    """Workspace member directories that have a local Cargo.toml."""
    out: list[Path] = []
    for child in sorted(root.iterdir()):
        if not child.is_dir() or child.name.startswith("."):
            continue
        if (child / "Cargo.toml").is_file():
            out.append(child)
    return out


def target_lean_for_crate(crate_dir: Path) -> Path:
    return crate_dir / "proofs" / "lean" / "extraction" / f"{crate_dir.name}.lean"


def ensure_interface_import_after_hax(lines: list[str], crate_name: str) -> list[str]:
    """Insert `import <crate>.interface` right after the first `import Hax` if missing."""
    want = f"import {crate_name}.interface"
    if any(line.strip() == want for line in lines):
        return lines

    out: list[str] = []
    inserted = False
    for line in lines:
        out.append(line)
        if not inserted and line.strip() == "import Hax":
            out.append(want)
            inserted = True
    return out


def main() -> int:
    root = multicrate_root()
    crate_dirs = discover_crate_dirs(root)
    try:
        for crate_dir in crate_dirs:
            subprocess.run(
                ["cargo", "hax", "into", "lean"],
                cwd=crate_dir,
                check=True,
            )
    except FileNotFoundError:
        print("error: `cargo` not found on PATH", file=sys.stderr)
        return 1
    except subprocess.CalledProcessError as e:
        return e.returncode

    for crate_dir in crate_dirs:
        lean_path = target_lean_for_crate(crate_dir)
        if not lean_path.is_file():
            continue
        orig_lines = lean_path.read_text(encoding="utf-8").splitlines()
        new_lines = ensure_interface_import_after_hax(orig_lines, crate_dir.name)
        if new_lines != orig_lines:
            lean_path.write_text("\n".join(new_lines) + "\n", encoding="utf-8")
            print(f"patched {lean_path.relative_to(root)}")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
