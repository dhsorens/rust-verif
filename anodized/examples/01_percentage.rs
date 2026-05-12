//! Preconditions and postconditions on a pure function.
//!
//! Run: `cargo run --example 01_percentage`

use anodized::spec;

#[spec(
    requires: [
        part >= 0.0,
        part <= whole,
        whole > 0.0,
    ],
    ensures: [
        *output >= 0.0,
        *output <= 100.0,
    ],
)]
fn calculate_percentage(part: f64, whole: f64) -> f64 {
    100.0 * part / whole
}

fn main() {
    println!("25 of 100 = {}%", calculate_percentage(25.0, 100.0));
    // Uncomment to see a precondition panic:
    // println!("{}", calculate_percentage(10.0, 0.0));
}
