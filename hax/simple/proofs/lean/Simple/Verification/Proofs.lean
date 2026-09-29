/- Proofs of the hand-written specifications in `Specs.lean`.

Each `<fn>.<property>.proof` discharges the matching definition in
`Specs.lean`. Where callers need to reason about a call to a function
without unfolding it, the property is also exposed as a Hoare triple
tagged `@[spec]` (a `<fn>.<property>.triple` theorem). `hax_mvcgen` only
picks up lemmas whose statement is literally a triple, so the
`abbrev`-wrapped form in `Specs.lean` is restated here.

Dependency direction: `Specs` <- `Proofs` <- `ProofObligations`. The
hax-generated contract proofs may reuse these triples; this file does not
depend on the generated contracts. -/
import Simple.Verification.Specs
open CoreModels Aeneas
open Aeneas.Std hiding namespace core alloc
open RustM ControlFlow Error
open Std.Do

set_option mvcgen.warning false
set_option hax_mvcgen.warnings false

namespace simple

/-! ## `add_u32` -/

theorem add_u32.exact_sum.proof (a b : Std.U32) : add_u32.exact_sum a b := by
  unfold add_u32.exact_sum add_u32
  hax_mvcgen
  grind

/-- `add_u32.exact_sum` as a `@[spec]` triple, for use by `hax_mvcgen` at call sites. -/
@[spec]
theorem add_u32.exact_sum.triple (a b : Std.U32) :
    ⦃ ⌜ a.val + b.val ≤ U32.max ⌝ ⦄ add_u32 a b ⦃ ⇓ r => ⌜ r.val = a.val + b.val ⌝ ⦄ :=
  add_u32.exact_sum.proof a b

theorem add_u32.comm.proof (a b : Std.U32) : add_u32.comm a b := by
  unfold add_u32.comm add_u32
  show UScalar.add a b = UScalar.add b a
  simp only [UScalar.add, Nat.add_comm]

/-! ## `double_u32` -/

/-- The call to `add_u32` is handled by `add_u32.exact_sum.triple`, not by unfolding. -/
theorem double_u32.exact.proof (x : Std.U32) : double_u32.exact x := by
  unfold double_u32.exact double_u32
  hax_mvcgen <;> grind

/-! ## `max_u32` -/

theorem max_u32.eq_max.proof (a b : Std.U32) : max_u32.eq_max a b := by
  unfold max_u32.eq_max max_u32
  hax_mvcgen <;> scalar_tac

end simple
