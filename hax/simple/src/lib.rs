//! Minimal safe Rust for hax → Lean extraction.
//!
//! Pre- and postconditions are attached with `hax_lib::requires` /
//! `hax_lib::ensures`. hax turns them into `<fn>.spec` definitions in
//! `proofs/lean/Simple/Extraction/Funs.lean`, which are proved in
//! `proofs/lean/Simple/Verification/ProofObligations.lean`.

// `to_int()` is only used inside the contracts, which hax compiles with `--cfg hax`.
#[cfg(hax)]
use hax_lib::int::*;

/// Add two unsigned 32-bit integers.
#[hax_lib::requires(a <= u32::MAX - b)]
#[hax_lib::ensures(|res| res.to_int() == a.to_int() + b.to_int())]
pub fn add_u32(a: u32, b: u32) -> u32 {
    a + b
}

/// Double a value (demonstrates a non-primitive call shape without recursion).
#[hax_lib::requires(x <= u32::MAX / 2)]
#[hax_lib::ensures(|res| res.to_int() == x.to_int() + x.to_int())]
pub fn double_u32(x: u32) -> u32 {
    add_u32(x, x)
}

/// Maximum of two `u32` values.
#[hax_lib::ensures(|res| res >= a && res >= b && (res == a || res == b))]
pub fn max_u32(a: u32, b: u32) -> u32 {
    if a >= b {
        a
    } else {
        b
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn smoke() {
        assert_eq!(add_u32(2, 3), 5);
        assert_eq!(double_u32(4), 8);
        assert_eq!(max_u32(1, 9), 9);
    }
}
