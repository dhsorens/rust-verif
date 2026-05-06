[Anneal](https://crates.io/crates/cargo-anneal) is a tool for dealing with *unsafe rust* which builds on Aeneas.

This directory is a small Cargo workspace with example crates that mirror patterns from [zerocopy’s `anneal/examples`](https://github.com/google/zerocopy/tree/main/anneal/examples). Use them as templates for `cargo anneal verify` on your own code.

## Prerequisites

Install and set up the toolchains (once per machine):

```bash
cargo install cargo-anneal@0.1.0-alpha.21
cargo anneal setup
```

## Example crates

| Crate | What it shows |
| ----- | ------------- |
| [`examples/update_max`](examples/update_max/) | Safe code, `&mut`, postconditions (`acc'`), and a short Lean proof. |
| [`examples/swap`](examples/swap/) | Two mutable references; separate `ensures` clauses for each updated place. |
| [`examples/unchecked_slice`](examples/unchecked_slice/) | **`unsafe`** slice indexing: `requires` / `ensures` with `unsafe(axiom)` so the proof obligation matches the raw access. |

From this directory:

```bash
cargo anneal verify -p update-max
cargo anneal verify -p swap
cargo anneal verify -p unchecked-slice
```

Useful debugging commands:

```bash
cargo anneal expand -p <package>
cargo anneal generate -p <package>
```

Upstream docs and quick start: [Anneal README on GitHub](https://github.com/google/zerocopy/blob/main/anneal/README.md).
