//! `requires` + `maintains` for a helper that mirrors `Vec::push` preconditions.
//!
//! Run: `cargo run --example 05_push_invariant`

use anodized::spec;

#[spec(
    requires: vec.len() < vec.capacity() || vec.capacity() == 0,
    maintains: vec.len() <= vec.capacity(),
    captures: vec.len() as old_len,
    ensures: vec.len() == old_len + 1,
)]
fn push_checked<T>(vec: &mut Vec<T>, value: T) {
    vec.push(value);
}

fn main() {
    let mut v = Vec::with_capacity(4);
    v.push(1);
    push_checked(&mut v, 2);
    println!("{:?}", v);
}
