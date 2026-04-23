
-- Experimental lean backend for Hax
-- The Hax prelude library can be found in hax/proof-libs/lean
import Hax
import Std.Tactic.Do
import Std.Do.Triple
import Std.Tactic.Do.Syntax
open Std.Do
open Std.Tactic

set_option mvcgen.warning false
set_option linter.unusedVariables false


namespace leaf_b

--  Returns a stable label for this crate.
@[spec]
def label (_ : rust_primitives.hax.Tuple0) : RustM String := do (pure "leaf_b")

--  A tiny pure function used by dependents.
@[spec]
def double (n : i32) : RustM i32 := do (n *? (2 : i32))

end leaf_b

