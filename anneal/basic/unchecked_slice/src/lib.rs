//! Unchecked slice element access: the safety proof lives in Anneal, not only in comments.
//!
//! Based on the upstream example:
//! <https://github.com/google/zerocopy/blob/main/anneal/examples/unchecked_get.rs>

/// Returns the element at index `i`.
///
/// ```lean, anneal, unsafe(axiom)
/// requires (h_bound): i < s.len
/// ensures: ret = s[i]'h_bound
/// ```
pub unsafe fn get_unchecked(s: &[u32], i: usize) -> u32 {
    unsafe { *s.get_unchecked(i) }
}
