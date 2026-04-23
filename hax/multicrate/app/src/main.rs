//! Binary crate that depends on both leaf crates (diamond-free tree: app → leaf_a, app → leaf_b).

fn main() {
    let n = 10;
    let x = leaf_a::bump(n);
    let y = leaf_b::double(x);
    println!(
        "{} + {}: bump({n}) = {x}, double({x}) = {y}",
        leaf_a::label(),
        leaf_b::label(),
    );
}
