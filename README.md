# To.ml

Ocaml parser for TOML (Tom's Obvious Minimal Language) (https://github.com/mojombo/toml)

## Dependencies

Compiled with **ocamlbuild** because it makes life easier for everyone.

This project use **ocamllex** and **menhir** parsing features. In order to
compile tests you will also need **OUnit**.

## Limitations

As Ocaml only handle ascii by default (regardless any external library), no support for UTF-8 is provided.

