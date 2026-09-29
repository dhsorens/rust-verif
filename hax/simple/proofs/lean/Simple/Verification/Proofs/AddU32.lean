/- Hand-written properties of `add_u32`. -/
import Simple.Extraction
import Hax
open CoreModels Aeneas
open Aeneas.Std hiding namespace core alloc
open RustM ControlFlow Error
open Std.Do

set_option mvcgen.warning false
set_option hax_mvcgen.warnings false

namespace simple

/-- Functional correctness with the precondition stated on mathematical
values: when the sum fits in a `u32`, `add_u32` returns exactly it.

Tagged `@[spec]` so `hax_mvcgen` can use it at call sites (see `double_u32`). -/
@[spec]
theorem add_u32.exact_sum (a b : Std.U32) :
    ⦃ ⌜ a.val + b.val ≤ U32.max ⌝ ⦄ add_u32 a b ⦃ ⇓ r => ⌜ r.val = a.val + b.val ⌝ ⦄ := by
  unfold add_u32
  hax_mvcgen
  grind

/-- `add_u32` is commutative *as a program*: the two calls are the same
`RustM` computation, so they agree on the result and on whether they
overflow. This is not expressible as a `hax_lib::ensures` clause. -/
theorem add_u32.comm (a b : Std.U32) : add_u32 a b = add_u32 b a := by
  unfold add_u32
  show UScalar.add a b = UScalar.add b a
  simp only [UScalar.add, Nat.add_comm]

end simple
