//! Leaf crate A: no dependencies beyond `std`.

/// Returns a stable label for this crate.
pub fn label() -> &'static str {
    "leaf_a"
}

/// A tiny pure function used by dependents.
pub fn bump(n: i32) -> i32 {
    n + 1
}
