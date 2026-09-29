/- Hand-written properties of `double_u32`. -/
import Simple.Verification.ProofObligations.AddU32
open CoreModels Aeneas
open Aeneas.Std hiding namespace core alloc
open RustM ControlFlow Error
open Std.Do

set_option mvcgen.warning false
set_option hax_mvcgen.warnings false

namespace simple

/-- When `2 * x` fits in a `u32`, `double_u32 x` returns exactly `2 * x`.

Only `double_u32` is unfolded; the call to `add_u32` is discharged by the
`@[spec]` theorem `add_u32.exact_sum`. -/
theorem double_u32.exact (x : Std.U32) :
    ⦃ ⌜ 2 * x.val ≤ U32.max ⌝ ⦄ double_u32 x ⦃ ⇓ r => ⌜ r.val = 2 * x.val ⌝ ⦄ := by
  unfold double_u32
  hax_mvcgen <;> grind

end simple
