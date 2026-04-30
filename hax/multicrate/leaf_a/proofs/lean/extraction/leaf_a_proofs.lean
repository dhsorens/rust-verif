import leaf_a
open leaf_a
open Std.Do

-- spec
#check bump

namespace bump_correct

-- spec
theorem bump_success (x : i32) :
  ⦃ ⌜ x + 1 < Int32.maxValue ⌝ ⦄ bump x ⦃ ⇓r => ⌜ r = x + 1 ⌝ ⦄ := by
  mvcgen
  intro h

  sorry

end bump_correct
