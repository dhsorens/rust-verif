/- Everything hand-written about the crate. hax never touches this file or
anything under `Simple/Verification/`.

- `ProofObligations`: proofs of the contracts hax extracted from the Rust
  `hax_lib::requires` / `hax_lib::ensures` attributes (mirrors the
  regenerated template in `Simple/Extraction/ProofObligations.lean`).
- `Proofs`: specifications stated only in Lean, with their proofs, one
  file per Rust function under `Proofs/`. -/
import Simple.Verification.Proofs
import Simple.Verification.ProofObligations
