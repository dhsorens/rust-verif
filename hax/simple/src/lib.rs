//! Minimal safe Rust for Aeneas → Lean extraction.
//!
//! See `aeneas/README.md` for the Charon + Aeneas workflow.

/// Add two unsigned 32-bit integers.
pub fn add_u32(a: u32, b: u32) -> u32 {
    a + b
}

/// Double a value (demonstrates a non-primitive call shape without recursion).
pub fn double_u32(x: u32) -> u32 {
    add_u32(x, x)
}

/// Maximum of two `u32` values.
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
