/- Hand-written specifications and their proofs, one file per Rust
function under `Proofs/`. These are properties stated directly in Lean,
independent of the `hax_lib::requires` / `hax_lib::ensures` contracts in
the Rust source (those are extracted to `Simple/Extraction/Specs.lean` and
proved in `ProofObligations.lean`). Both kinds coexist.

Conventions:
- Name theorems `<fn>.<property>`. Avoid `<fn>.spec`, `.pre`, `.post`,
  which hax reserves for the generated contract.
- State functional properties as Hoare triples and tag the ones callers
  need with `@[spec]`, so `hax_mvcgen` can use them at call sites without
  unfolding the callee. `hax_mvcgen` only picks up lemmas whose statement
  is literally a triple.
- `ProofObligations.lean` imports this file and may reuse its `@[spec]`
  theorems; nothing here depends on the generated contracts. -/
import Simple.Verification.Proofs.AddU32
import Simple.Verification.Proofs.DoubleU32
import Simple.Verification.Proofs.MaxU32
