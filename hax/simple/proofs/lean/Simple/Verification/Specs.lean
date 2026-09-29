/- Hand-written specifications.

These are properties stated directly in Lean, independent of the
`hax_lib::requires` / `hax_lib::ensures` contracts in the Rust source
(those are extracted by hax into `Simple/Extraction/Specs.lean` and
proved in `Simple/Verification/ProofObligations.lean`). Both kinds of
spec coexist; this file only adds to what the Rust contracts say.

This file contains statements only. Proofs live in `Proofs.lean`, so
that what is claimed about the crate can be read without tactics, in the
same way `Extraction/Specs.lean` is separate from its proof obligations.

Naming: `<fn>.<property>`. Avoid `<fn>.spec`, `<fn>.pre` and `<fn>.post`,
which hax reserves for the generated contract. -/
import Simple.Extraction
import Hax
open CoreModels Aeneas
open Aeneas.Std hiding namespace core alloc
open RustM ControlFlow Error
open Std.Do

namespace simple

/-! ## `add_u32` -/

/-- Functional correctness with a precondition stated on the mathematical
values: when the sum fits in a `u32`, `add_u32` returns exactly it. -/
abbrev add_u32.exact_sum (a b : Std.U32) : Prop :=
  ⦃ ⌜ a.val + b.val ≤ U32.max ⌝ ⦄ add_u32 a b ⦃ ⇓ r => ⌜ r.val = a.val + b.val ⌝ ⦄

/-- `add_u32` is commutative as a program: the two calls produce the same
`RustM` computation, so they agree on the result *and* on whether they
overflow. This is not expressible as a `hax_lib::ensures` clause. -/
abbrev add_u32.comm (a b : Std.U32) : Prop :=
  add_u32 a b = add_u32 b a

/-! ## `double_u32` -/

/-- When `2 * x` fits in a `u32`, `double_u32 x` returns exactly `2 * x`. -/
abbrev double_u32.exact (x : Std.U32) : Prop :=
  ⦃ ⌜ 2 * x.val ≤ U32.max ⌝ ⦄ double_u32 x ⦃ ⇓ r => ⌜ r.val = 2 * x.val ⌝ ⦄

/-! ## `max_u32` -/

/-- `max_u32` never fails and returns the mathematical maximum. -/
abbrev max_u32.eq_max (a b : Std.U32) : Prop :=
  ⦃ ⌜ True ⌝ ⦄ max_u32 a b ⦃ ⇓ r => ⌜ r.val = max a.val b.val ⌝ ⦄

end simple
