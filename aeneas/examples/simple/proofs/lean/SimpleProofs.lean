import Simple
import Aeneas
open Aeneas Aeneas.Std Result

set_option maxHeartbeats 1000000

#setup_aeneas_simps

namespace simple

/-- Specification for the extracted `add_u32` (integer addition without overflow). -/
theorem add_u32_spec (a b : Std.U32) (h : a.val + b.val ≤ UInt32.size - 1) :
    add_u32 a b ⦃ c => ↑c = (↑a : Int) + (↑b : Int) ⦄ := by
  unfold add_u32
  step as ⟨ c ⟩
  scalar_tac

/-- `double_u32` doubles its input via `add_u32`. -/
theorem double_u32_spec (x : Std.U32) (h : 2 * x.val ≤ UInt32.size - 1) :
    double_u32 x ⦃ y => ↑y = 2 * (↑x : Int) ⦄ := by
  unfold double_u32
  step with add_u32_spec as ⟨ y ⟩
  scalar_tac

/-- `max_u32` returns the greater of its arguments. -/
theorem max_u32_spec (a b : Std.U32) :
    max_u32 a b ⦃ m => m.val = max a.val b.val ⦄ := by
  unfold max_u32
  split <;> (step <;> scalar_tac)

end simple
