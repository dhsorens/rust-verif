[Anodized](https://crates.io/crates/anodized) is a specification framework for Rust code.

This directory contains a small crate **`anodized_showcase`** with runnable examples under `examples/`. From `anodized/`:

```bash
cargo run --example 01_percentage
cargo run --example 02_sort_pair
cargo run --example 03_withdraw
cargo run --example 04_trait_monotonic
cargo run --example 05_push_invariant
cargo run --example 06_search
```

| Example | Highlights |
|--------|------------|
| `01_percentage` | `requires` / `ensures` lists on a pure function |
| `02_sort_pair` | `binds:` with tuple destructuring in postconditions |
| `03_withdraw` | `captures`, `maintains`, and tuple `binds` on `&mut` state |
| `04_trait_monotonic` | `#[spec]` on a trait + method postcondition with `captures` |
| `05_push_invariant` | `requires` + `maintains` + `captures` / `ensures` for `Vec` |
| `06_search` | `match` in a postcondition (specs are ordinary Rust `bool` expressions) |

Upstream docs and API: [docs.rs/anodized](https://docs.rs/anodized/latest/anodized/), [github.com/mkovaxx/anodized](https://github.com/mkovaxx/anodized).