//! Destructuring the return value in postconditions with `binds`.
//!
//! Run: `cargo run --example 02_sort_pair`

use anodized::spec;

#[spec(
    binds: (a, b),
    ensures: [
        *a <= *b,
        (*a, *b) == pair || (*b, *a) == pair,
    ],
)]
fn sort_pair(pair: (i32, i32)) -> (i32, i32) {
    let (x, y) = pair;
    if x <= y {
        (x, y)
    } else {
        (y, x)
    }
}

fn main() {
    println!("{:?} -> {:?}", (3, 1), sort_pair((3, 1)));
    println!("{:?} -> {:?}", (2, 2), sort_pair((2, 2)));
}
