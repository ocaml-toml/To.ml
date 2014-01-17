# To.ml

Ocaml parser for TOML (Tom's Obvious Minimal Language) (https://github.com/mojombo/toml)

## Dependencies

Compiled with **ocamlbuild** because it makes life easier for everyone.

This project use **ocamllex** and **menhir** parsing features. In order to
compile tests you will also need **OUnit**.

## Limitations

Due to OCaml limits (regardless any external library):
* No support for UTF-8
* No support for date (parsed as string, even if typed as date)
