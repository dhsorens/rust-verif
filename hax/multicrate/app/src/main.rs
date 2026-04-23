//! Binary crate that depends on both leaf crates (diamond-free tree: app → leaf_a, app → leaf_b).

fn combine(n: i32) -> i32 {
    let x = leaf_a::bump(n);
    let y = leaf_b::double(x);
    x + y
}

fn main() {
    let _ = combine(10);
}
