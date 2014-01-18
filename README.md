# To.ml

[![Build Status](https://travis-ci.org/mackwic/To.ml.png?branch=master)](https://travis-ci.org/mackwic/To.ml)

Ocaml parser for TOML (Tom's Obvious Minimal Language) (https://github.com/mojombo/toml)

## Dependencies

To.ml need Ocaml 4.0 at least. Check your local installation with `ocamlc -v`.

This project use **ocamllex** and **menhir** parsing features. In order to
compile tests you will also need **OUnit**.

## Limitations

Due to OCaml limits (regardless any external library):
* No support for UTF-8
* No support for date (parsed as string, even if typed as date)
