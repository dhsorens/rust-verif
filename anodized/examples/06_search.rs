//! Using ordinary Rust in specs (`matches!`, options).
//!
//! Run: `cargo run --example 06_search`

use anodized::spec;

#[spec(
    requires: !haystack.is_empty(),
    ensures: match *output {
        Some(i) => i < haystack.len() && haystack[i] == needle,
        None => !haystack.contains(&needle),
    },
)]
fn find_first(haystack: &[i32], needle: i32) -> Option<usize> {
    haystack.iter().position(|&x| x == needle)
}

fn main() {
    let xs = [10, 20, 30];
    println!("find 20: {:?}", find_first(&xs, 20));
    println!("find 99: {:?}", find_first(&xs, 99));
}
