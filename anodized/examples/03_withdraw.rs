//! `captures` for entry-time state, `maintains` for a bank invariant, tuple return.
//!
//! Run: `cargo run --example 03_withdraw`

use anodized::spec;

/// Signed balance so a non-negativity invariant is meaningful for tooling and readers.
#[spec(
    requires: [
        amount >= 0,
        *balance >= amount,
    ],
    maintains: *balance >= 0,
    captures: *balance as initial_balance,
    binds: (new_balance, receipt_amount),
    ensures: [
        *new_balance == initial_balance - amount,
        *receipt_amount == amount,
        *balance == *new_balance,
    ],
)]
#[allow(unused_variables)] // binds names are spec-only; rustc can still warn on the pattern
fn withdraw(balance: &mut i64, amount: i64) -> (i64, i64) {
    *balance -= amount;
    (*balance, amount)
}

fn main() {
    let mut acct = 100i64;
    let (left, cash) = withdraw(&mut acct, 30);
    println!("balance after: {}, withdrew: {}, (returned pair: {}, {})", acct, cash, left, cash);
}
