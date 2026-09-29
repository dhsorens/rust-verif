/- Proofs of the contracts hax extracted from the Rust source.

The `hax_lib::requires` / `hax_lib::ensures` attributes are extracted to
`<fn>.pre`, `<fn>.post` and `<fn>.spec` in `Simple/Extraction/Specs.lean`,
and hax regenerates a `sorry` template of the theorems below in
`Simple/Extraction/ProofObligations.lean` on every run. This file is the
1:1 answer to that template and should contain nothing else, so the two
can be diffed after re-extraction. hax never modifies anything under
`Verification/`.

Recipe: `unfold` the spec, its pre/post and the function, let
`hax_mvcgen` generate the verification conditions, and close them with
`grind` / `scalar_tac`. Calls to already-verified functions are handled
by the `@[spec]` theorems under `Proofs/` (here: `add_u32.exact_sum`
for the call inside `double_u32`). -/
import Simple.Extraction
import Simple.Verification.Proofs
import Hax
open CoreModels Aeneas
open Aeneas.Std hiding namespace core alloc
open RustM ControlFlow Error
open Std.Do

set_option mvcgen.warning false
set_option hax_mvcgen.warnings false

namespace simple

/-! ## `add_u32` -/

/-- `add_u32 a b` returns exactly `a + b` whenever `a <= u32::MAX - b`.
This is the contract exactly as hax extracted it from the Rust attributes. -/
theorem add_u32.spec.proof (a b : Std.U32) : add_u32.spec a b := by
  unfold add_u32.spec add_u32.pre add_u32.post add_u32
  hax_mvcgen <;> grind [U32.rMax]

/-! ## `double_u32` -/

/-- `double_u32 x` returns `x + x` whenever `x <= u32::MAX / 2`.
`add_u32` is not unfolded: the call is handled by `add_u32.exact_sum`. -/
theorem double_u32.spec.proof (x : Std.U32) : double_u32.spec x := by
  unfold double_u32.spec double_u32.pre double_u32.post double_u32
  hax_mvcgen <;> grind [U32.rMax]

/-! ## `max_u32` -/

/-- `max_u32 a b` is at least each argument and equal to one of them. -/
theorem max_u32.spec.proof (a b : Std.U32) : max_u32.spec a b := by
  unfold max_u32.spec max_u32.post max_u32
  hax_mvcgen <;> grind

end simple
