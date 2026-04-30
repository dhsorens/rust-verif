import app
import leaf_a
import leaf_a_proofs
import leaf_b
import leaf_b_proofs
open Std.Do

#check Nat

#check leaf_b.double
#check double_correct.double_success
#check bump_correct.bump_success

namespace combine_correct

theorem combine_success (x : i32) :
  ⦃⌜3 * (x + 1) < Int32.maxValue⌝⦄ app.combine x
  ⦃Std.Do.PostCond.noThrow fun r => ⌜r = x + 1⌝⦄ := by sorry


end combine_correct
