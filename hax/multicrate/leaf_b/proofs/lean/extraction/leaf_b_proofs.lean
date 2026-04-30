import leaf_b
open leaf_b
open Std.Do

-- spec
#check double

namespace double_correct

-- spec
theorem double_success (x : i32) :
  ⦃ ⌜ 2 * x < Int32.maxValue ⌝ ⦄ double x ⦃ ⇓r => ⌜ r = 2 * x ⌝ ⦄ := by
  mvcgen
  intro h

  sorry

end double_correct
