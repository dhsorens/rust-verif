/- Hand-written properties of `max_u32`. -/
import Simple.Extraction
import Hax
open CoreModels Aeneas
open Aeneas.Std hiding namespace core alloc
open RustM ControlFlow Error
open Std.Do

set_option mvcgen.warning false
set_option hax_mvcgen.warnings false

namespace simple

/-- `max_u32` never fails and returns the mathematical maximum. -/
theorem max_u32.eq_max (a b : Std.U32) :
    ⦃ ⌜ True ⌝ ⦄ max_u32 a b ⦃ ⇓ r => ⌜ r.val = max a.val b.val ⌝ ⦄ := by
  unfold max_u32
  hax_mvcgen <;> scalar_tac

end simple
