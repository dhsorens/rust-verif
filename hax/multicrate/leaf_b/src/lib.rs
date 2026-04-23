//! Leaf crate B: no dependencies beyond `std`.

/// Returns a stable label for this crate.
pub fn label() -> &'static str {
    "leaf_b"
}

/// A tiny pure function used by dependents.
pub fn double(n: i32) -> i32 {
    n * 2
}
