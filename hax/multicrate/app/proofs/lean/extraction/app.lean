
-- Experimental lean backend for Hax
-- The Hax prelude library can be found in hax/proof-libs/lean
import Hax
import Std.Tactic.Do
import Std.Do.Triple
import Std.Tactic.Do.Syntax
import leaf_a
import leaf_b
open Std.Do
open Std.Tactic

set_option mvcgen.warning false
set_option linter.unusedVariables false


namespace app

@[spec]
def combine (n : i32) : RustM i32 := do
  let x : i32 ← (leaf_a.bump n);
  let y : i32 ← (leaf_b.double x);
  (x +? y)

@[spec]
def main (_ : rust_primitives.hax.Tuple0) :
    RustM rust_primitives.hax.Tuple0 := do
  let _ ← (combine (10 : i32));
  (pure rust_primitives.hax.Tuple0.mk)

end app
