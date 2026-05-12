//! Specs on a trait: requirements on all implementations.
//!
//! Run: `cargo run --example 04_trait_monotonic`
//!
//! Note: put `#[spec(...)]` on trait methods at the trait definition; the impl
//! only needs the trait-level `#[spec]` attribute.

use anodized::spec;

#[spec]
trait MonotonicGenerator {
    fn current(&self) -> i32;

    #[spec(
        captures: self.current() as old_val,
        ensures: self.current() > old_val,
    )]
    fn update(&mut self);
}

struct Counter(i32);

#[spec]
impl MonotonicGenerator for Counter {
    fn current(&self) -> i32 {
        self.0
    }

    fn update(&mut self) {
        self.0 += 1;
    }
}

fn main() {
    let mut c = Counter(0);
    println!("start: {}", c.current());
    c.update();
    println!("after update: {}", c.current());
}
