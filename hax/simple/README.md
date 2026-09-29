# `simple`: verifying Rust with hax and Lean

A minimal, fully worked example of the hax → Lean pipeline. Three small
`u32` functions are extracted to Lean, their Rust-side contracts are
proved, and a few extra properties that only exist in Lean are proved
alongside them.

Contents:

1. [The pipeline in one picture](#1-the-pipeline-in-one-picture)
2. [File structure](#2-file-structure)
3. [Prerequisites](#3-prerequisites)
4. [The Rust side: contracts as attributes](#4-the-rust-side-contracts-as-attributes)
5. [Running the extraction](#5-running-the-extraction)
6. [What hax generates](#6-what-hax-generates)
7. [Proving the generated contracts](#7-proving-the-generated-contracts)
8. [Adding hand-written specs and proofs](#8-adding-hand-written-specs-and-proofs)
9. [Reusing a verified function at its call sites](#9-reusing-a-verified-function-at-its-call-sites)
10. [Day-to-day workflow](#10-day-to-day-workflow)
11. [Troubleshooting](#11-troubleshooting)

---

## 1. The pipeline in one picture

```
src/lib.rs                      Rust, with #[hax_lib::requires] / #[hax_lib::ensures]
    │  cargo hax into lean
    ├─► Charon                  compiles the crate (with --cfg hax) to LLBC
    │       proofs/lean/llbc/simple.llbc
    └─► Aeneas (Cryspen fork)   translates LLBC to Lean in the RustM monad
            proofs/lean/Simple/Extraction/*.lean     ← regenerated every run
            proofs/lean/Simple/Assumptions/*.lean    ← created once
            proofs/lean/Simple/Verification/*.lean   ← created once, yours

lake build                      checks extraction + all proofs
```

Two kinds of specification live side by side:

| Kind | Stated in | Extracted to | Proved in |
|---|---|---|---|
| Rust contracts | `src/lib.rs` attributes | `Simple/Extraction/Specs.lean` | `Simple/Verification/ProofObligations.lean` |
| Lean-only specs | `Simple/Verification/Proofs/*.lean` | — | same file, next to the statement |

## 2. File structure

Every file in the example, with what it is for. The marker on the right
says who edits a file: **hax** rewrites it on every extraction, **once**
means hax creates it the first time and never again, **you** means it is
hand-written, **cargo** / **lake** means the tool maintains it.

```
hax/simple/
├── README.md                          this tutorial                                   you
├── Cargo.toml                         crate manifest; depends on hax-lib,
│                                      declares the `hax` cfg for cargo                 you
├── Cargo.lock                         locked Rust dependencies                         cargo
├── src/
│   └── lib.rs                         the Rust code, with #[hax_lib::requires] /
│                                      #[hax_lib::ensures] contracts                    you
└── proofs/lean/                       Lake project "simple"
    ├── lakefile.toml                  Lake config: one library `Simple`; requires
    │                                  Cryspen's Aeneas fork and hax-lean               once
    ├── lean-toolchain                 pins the Lean version for elan                   once
    ├── lake-manifest.json             exact revisions of every Lean dependency         lake
    ├── .gitignore                     ignores llbc/, .lake/, aeneas-error.log          once
    ├── llbc/
    │   └── simple.llbc                Charon's output, input to Aeneas; ignored        hax
    ├── Simple.lean                    library root: imports Simple.Extraction and
    │                                  Simple.Verification                              once
    └── Simple/
        ├── Extraction.lean            imports Types, Funs, Specs                       hax
        ├── Extraction/
        │   ├── Types.lean             extracted type definitions (none here)           hax
        │   ├── Funs.lean              extracted functions, in the RustM monad          hax
        │   ├── Specs.lean             <fn>.pre / .post / .spec built from the
        │   │                          Rust contracts                                   hax
        │   ├── ProofObligations.lean  `sorry` template listing the theorems to
        │   │                          prove; not imported, a checklist                 hax
        │   ├── FunsExternal.lean      re-exports Assumptions/FunsExternal              hax
        │   ├── TypesExternal.lean     re-exports Assumptions/TypesExternal             hax
        │   ├── FunsExternal_Template.lean
        │   │                          fresh template to diff Assumptions against       hax
        │   └── TypesExternal_Template.lean
        │                              fresh template to diff Assumptions against       hax
        ├── Assumptions/
        │   ├── FunsExternal.lean      axioms for opaque external functions (empty)     once
        │   └── TypesExternal.lean     axioms for opaque external types (empty)         once
        ├── Verification.lean          aggregator: imports Specs, Proofs,
        │                              ProofObligations                                 you
        └── Verification/
            ├── ProofObligations.lean  proofs of the generated contracts; a 1:1
            │                          mirror of Extraction/ProofObligations.lean       you*
            ├── Proofs.lean            imports everything under Proofs/                 you
            └── Proofs/                Lean-only specs with their proofs, one file
                │                      per Rust function                                you
                ├── AddU32.lean        add_u32.exact_sum (@[spec]), add_u32.comm
                ├── DoubleU32.lean     double_u32.exact, via add_u32.exact_sum
                └── MaxU32.lean        max_u32.eq_max

* hax creates Verification/ProofObligations.lean as an empty stub on the
  first run and never touches it afterwards.
```

Three ownership tiers:

- **`Extraction/`** is regenerated wholesale on every run. Never edit it.
- **`Assumptions/`** is seeded once with holes for external items that
  hax could not translate, then left alone. After a re-extraction, diff
  each file against its `_Template` sibling under `Extraction/` to see
  what changed. This crate has no external items, so both files are empty.
- **`Verification/`** is created once as an empty stub and is entirely
  hand-maintained. `Simple.lean` is also created only once, which is why
  it is safe to point it at the `Simple.Verification` aggregator.

Import order inside `Verification/` is `Proofs/*` → `Proofs` →
`ProofObligations`: the generated-contract proofs may reuse hand-written
results, but not the other way round, so there are no cycles.

What is hax's and what is this project's: hax creates `Verification/`,
the `ProofObligations.lean` stub, and the `<fn>.spec.proof` convention,
and its own examples put every hand-written theorem into that one file.
`Verification.lean`, `Proofs.lean` and the `Proofs/` directory are a
layout chosen here to keep Lean-only properties apart from the answers
to the generated template; hax neither expects nor checks them.

## 3. Prerequisites

- `cargo hax` 0.4.1 or later, installed as described in the
  [hax repo](https://github.com/cryspen/hax). hax manages its own Charon
  and Aeneas binaries; `cargo hax tools show` prints the active versions.
- A Rust toolchain via `rustup`. hax pulls the nightly it needs.
- `elan` for Lean. `proofs/lean/lean-toolchain` pins the Lean version and
  `elan` installs it on first `lake build`.
- Roughly 8 GB of disk for the Lean dependencies (Mathlib is pulled in via
  Aeneas; its build cache is downloaded rather than compiled).

## 4. The Rust side: contracts as attributes

`src/lib.rs` is ordinary Rust plus `hax_lib` attributes:

```rust
// `to_int()` is only used inside the contracts, which hax compiles with `--cfg hax`.
#[cfg(hax)]
use hax_lib::int::*;

#[hax_lib::requires(a <= u32::MAX - b)]
#[hax_lib::ensures(|res| res.to_int() == a.to_int() + b.to_int())]
pub fn add_u32(a: u32, b: u32) -> u32 {
    a + b
}

#[hax_lib::requires(x <= u32::MAX / 2)]
#[hax_lib::ensures(|res| res.to_int() == x.to_int() + x.to_int())]
pub fn double_u32(x: u32) -> u32 {
    add_u32(x, x)
}

#[hax_lib::ensures(|res| res >= a && res >= b && (res == a || res == b))]
pub fn max_u32(a: u32, b: u32) -> u32 {
    if a >= b { a } else { b }
}
```

Points to note:

- `requires` is a precondition, `ensures` a postcondition over the result
  (`|res|`). Both are ordinary Rust expressions, so they must themselves
  not overflow: `a <= u32::MAX - b` is fine because `b <= u32::MAX`.
- `.to_int()` from `hax_lib::int` lifts to unbounded integers, so a
  postcondition like `res == a + b` can be stated without worrying about
  wraparound.
- The attributes expand to nothing under plain `cargo build`/`cargo test`,
  so the crate compiles and runs normally. The `hax_lib::int` import is
  gated on `#[cfg(hax)]` for that reason, and `Cargo.toml` declares the
  `hax` cfg under `[lints.rust]` so cargo does not warn about it.
- `Cargo.toml` depends on `hax-lib = "0.4.1"`; keep it in step with the
  `cargo hax` version.

## 5. Running the extraction

From this directory:

```sh
cargo hax into lean
```

This runs Charon, writes `proofs/lean/llbc/simple.llbc`, runs Aeneas on
it, and reports every Lean file it wrote. On a first run it also creates
the Lake project (`lakefile.toml`, `lean-toolchain`, `.gitignore`), the
`Assumptions/` stubs, and an empty `Verification/ProofObligations.lean`.

Then check everything:

```sh
cd proofs/lean
lake build
```

The first build fetches the Cryspen Aeneas fork, the `hax-lean` support
library, and Mathlib (from its binary cache). Later builds are incremental.

## 6. What hax generates

`Extraction/Funs.lean` contains the functions in the `RustM` monad, which
tracks success (`ok`), panics (`fail`) and divergence. Integer types are
Aeneas's bounded scalars (`Std.U32`), and `+` on them is monadic: it
fails on overflow.

```lean
def add_u32 (a : Std.U32) (b : Std.U32) : RustM Std.U32 := do
  a + b

def double_u32 (x : Std.U32) : RustM Std.U32 := do
  add_u32 x x

def max_u32 (a : Std.U32) (b : Std.U32) : RustM Std.U32 := do
  if a >= b then ok a else ok b
```

`Extraction/Specs.lean` turns each contract into three definitions. The
pre- and postconditions are themselves `RustM Bool` programs (the Rust
expressions, extracted), and the spec is a Hoare triple guarded by the
precondition:

```lean
@[reducible]
def add_u32.pre (a : Std.U32) (b : Std.U32) : RustM Bool := do
  let i ← core.num.U32.MAX - b
  ok (a <= i)

@[reducible]
def add_u32.post (a : Std.U32) (b : Std.U32) (res : Std.U32) : RustM Bool := do
  ...  -- res.to_int() == a.to_int() + b.to_int(), extracted

def add_u32.spec (a : Std.U32) (b : Std.U32) : Prop :=
  (add_u32.pre a b).holds →
  ⦃ ⌜ True ⌝ ⦄ add_u32 a b ⦃ ⇓ res => ⌜ (add_u32.post a b res).holds ⌝ ⦄
```

`⦃ P ⦄ prog ⦃ ⇓ r => Q r ⦄` is Lean's `Std.Do` Hoare triple: if `P`
holds, `prog` terminates without panicking and its result satisfies `Q`.
`(x).holds` means the Boolean program `x` runs successfully and returns
`true`.

`Extraction/ProofObligations.lean` is a checklist: one theorem
`<fn>.spec.proof : <fn>.spec …` per contract, each ending in `sorry`. It
is regenerated every run and is *not* imported by anything. Its purpose is
to show what still needs proving.

## 7. Proving the generated contracts

Proofs go in `Verification/ProofObligations.lean`, kept as a strict 1:1
mirror of the template so the two can be diffed after every
re-extraction. Every proof follows the same recipe:

1. `unfold` the spec, its `pre`/`post`, and the function.
2. `hax_mvcgen` generates the verification conditions. It is hax's
   extension of Lean's `mvcgen` that understands triples nested in pre-
   and postconditions.
3. Close the remaining arithmetic goals with `grind` or `scalar_tac`
   (Aeneas's `omega` front end for bounded scalars).

```lean
theorem add_u32.spec.proof (a b : Std.U32) : add_u32.spec a b := by
  unfold add_u32.spec add_u32.pre add_u32.post add_u32
  hax_mvcgen <;> grind [U32.rMax]

theorem max_u32.spec.proof (a b : Std.U32) : max_u32.spec a b := by
  unfold max_u32.spec max_u32.post max_u32
  hax_mvcgen <;> grind
```

`U32.rMax` is the numeral behind `core.num.U32.MAX`; `grind` needs it
unfolded to relate the Rust-level precondition to the overflow bound.

## 8. Adding hand-written specs and proofs

Not everything is expressible as a Rust attribute, and sometimes a
cleaner mathematical statement is wanted. Those live under
`Verification/Proofs/`, one file per Rust function, and each theorem is
its own specification: the statement is a Hoare triple (or a plain
equation) and the proof follows immediately. `Verification/Proofs.lean`
just imports the directory.

```lean
-- Proofs/AddU32.lean

/-- When the sum fits in a `u32`, `add_u32` returns exactly it. -/
@[spec]
theorem add_u32.exact_sum (a b : Std.U32) :
    ⦃ ⌜ a.val + b.val ≤ U32.max ⌝ ⦄ add_u32 a b ⦃ ⇓ r => ⌜ r.val = a.val + b.val ⌝ ⦄ := by
  unfold add_u32
  hax_mvcgen
  grind

/-- Commutative *as a program*: same result and same overflow behaviour.
    Not expressible as a `hax_lib::ensures` clause. -/
theorem add_u32.comm (a b : Std.U32) : add_u32 a b = add_u32 b a := by
  unfold add_u32
  show UScalar.add a b = UScalar.add b a
  simp only [UScalar.add, Nat.add_comm]
```

```lean
-- Proofs/MaxU32.lean

/-- `max_u32` never fails and returns the mathematical maximum. -/
theorem max_u32.eq_max (a b : Std.U32) :
    ⦃ ⌜ True ⌝ ⦄ max_u32 a b ⦃ ⇓ r => ⌜ r.val = max a.val b.val ⌝ ⦄ := by
  unfold max_u32
  hax_mvcgen <;> scalar_tac
```

Triples are proved with the same recipe as the generated contracts.
Equalities of programs are proved by unfolding down to Aeneas's scalar
operations. Name theorems `<fn>.<property>` and avoid `<fn>.spec`,
`.pre`, `.post`, which hax reserves.

To add a property for a new function, create `Proofs/<Fn>.lean` and add
one `import` line to `Proofs.lean`.

## 9. Reusing a verified function at its call sites

`double_u32` calls `add_u32`. To verify the caller without unfolding the
callee, `hax_mvcgen` looks for lemmas tagged `@[spec]` whose statement is
**literally a Hoare triple**. That is why `add_u32.exact_sum` above
carries `@[spec]`. The generated `<fn>.spec` is *not* picked up, because
it is an implication (`pre.holds → ⦃…⦄ …`) rather than a bare triple, and
neither is a triple hidden behind a definition.

With `add_u32.exact_sum` in scope, both the hand-written `double_u32.exact`
and the generated-contract `double_u32.spec.proof` go through by
unfolding only `double_u32`:

```lean
-- Proofs/DoubleU32.lean
theorem double_u32.exact (x : Std.U32) :
    ⦃ ⌜ 2 * x.val ≤ U32.max ⌝ ⦄ double_u32 x ⦃ ⇓ r => ⌜ r.val = 2 * x.val ⌝ ⦄ := by
  unfold double_u32
  hax_mvcgen <;> grind
```

The call to `add_u32` is discharged from the `@[spec]` theorem, leaving a
side goal that its precondition holds. `ProofObligations.lean` imports
`Proofs.lean` for the same reason.

If a call is not handled, `hax_mvcgen` stops with a goal of the form
`wp⟦add_u32 x x⟧ …`, which is the signal that a `@[spec]` triple for
that function is missing.

## 10. Day-to-day workflow

1. Edit `src/lib.rs`, adjusting contracts as needed. `cargo test` still
   works as usual.
2. `cargo hax into lean`. Only `Extraction/` changes.
3. Diff `Simple/Extraction/ProofObligations.lean` against
   `Simple/Verification/ProofObligations.lean`. Any theorem in the
   template that is missing from the mirror is a new or changed contract
   to prove.
4. If hax reports new external items, fill the holes in `Assumptions/`
   using the regenerated `_Template` files as a guide.
5. Add or update Lean-only properties under `Verification/Proofs/`.
6. `cd proofs/lean && lake build`.

What is committed: the Rust crate, the whole `proofs/lean` tree except
`llbc/` and `.lake/` (both gitignored), including `lake-manifest.json` so
dependency revisions are reproducible.

## 11. Troubleshooting

- **`E0514: found crate std compiled by an incompatible version of rustc`
  during `cargo hax`.** Charon builds a Miri-style sysroot and caches its
  location per toolchain under `~/.cache/charon/full-mir-sysroot-cache/`.
  If another Charon (for example the one bundled with a separate Aeneas
  checkout, on a different nightly) rebuilt the shared default sysroot,
  the pointer goes stale. Fix: delete the pointer file for hax's toolchain
  and re-run with a private sysroot directory, which Charon then remembers:

  ```sh
  rm ~/.cache/charon/full-mir-sysroot-cache/<nightly>-aarch64-apple-darwin
  MIRI_SYSROOT=~/.cache/charon/miri-sysroot-<nightly> cargo hax into lean
  ```

- **`hax_mvcgen` leaves a `wp⟦f …⟧` goal.** A `@[spec]` triple for `f` is
  missing; see section 9.

- **`grind` fails on a goal mentioning `core.num.U32.MAX`.** Add
  `U32.rMax` to the simp set: `grind [U32.rMax]`.

- **`unused import: hax_lib::int::*` from cargo.** Gate the import on
  `#[cfg(hax)]` and declare the cfg in `Cargo.toml`, as this crate does.

- **Disk full during the first `lake build`.** The Lean dependencies need
  roughly 8 GB. Each Lake project keeps its own copy under `.lake/`, so
  old projects are the usual place to reclaim space.
