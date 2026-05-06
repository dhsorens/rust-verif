//! Swaps two `u32` values through mutable references.
//!
//! Based on the upstream example:
//! <https://github.com/google/zerocopy/blob/main/anneal/examples/swap.rs>

/// Swaps two values.
///
/// ```lean, anneal, spec
/// ensures(h_x'_eq_y): x' = y
/// ensures(h_y'_eq_x): y' = x
/// proof (h_progress):
///   unfold swap
///   simp_all
/// ```
#[allow(clippy::manual_swap)]
pub fn swap(x: &mut u32, y: &mut u32) {
    let tmp = *x;
    *x = *y;
    *y = tmp;
}
