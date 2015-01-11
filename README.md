# Toml (OCaml parser for TOML)

[![Build Status](https://travis-ci.org/mackwic/To.ml.png?branch=master)](https://travis-ci.org/mackwic/To.ml)
[![Coverage
Status](https://coveralls.io/repos/mackwic/To.ml/badge.png?branch=master)](https://coveralls.io/r/mackwic/To.ml?branch=master)

OCaml parser for TOML [(Tom's Obvious Minimal Language)](https://github.com/mojombo/toml) v0.2.0.

## Table of contents

- [A foreword to beginners](#a-foreword-to-beginners)
- [Dependencies](#dependencies)
- [Install](#install)
- [Usage](#usage)
- [Reading Toml data](#reading-toml-data)
- [Writing Toml data](#writing-toml-data)
- [Limitations](#limitations)

## A foreword to beginners

New to Ocaml ? Don't worry, just check theses links to begin with:

- [Play with Ocaml online and discover the language](http://try.ocamlpro.com/)
- [See Ocaml code examples](http://rosettacode.org/wiki/Category:OCaml)
- [The full official list of Ocaml tutorials](http://ocaml.org/learn/tutorials/)
- Recommanded tools:
    - [Ocaml Package Manager](https://opam.ocaml.org) (also install compilers)
    - [Ocaml IDE](http://www.algo-prog.info/ocaide/install.php)
    - [Ocaml Interpretor](https://github.com/diml/utop)

## Dependencies

Toml need OCaml 4.0 at least. Check your local installation with `ocamlc -v`.

This project use **ocamllex** and **menhir** parsing features. In order to
compile tests you will also need **OUnit** and **bisect** is required to
generate code coverage summary.

## Install

* Via Opam: `opam install toml`
* From source:
```bash
git clone https://github.com/sagotch/To.ml
cd To.ml
make build
make install
```
make install may need sudo.

## Usage

`open Toml` in your file(s), and link toml library when compiling. For
instance, using ocamlbuild:
```bash
ocamlbuild -use-ocamlfind -package toml foo.byte
```
or using an ocaml toplevel (like utop):
```bash
$ utop
utop # #use "topfind";;
utop # #require "toml";; (* now you can use the Toml module *)
```

### Reading Toml data

```ocaml
utop # let parsed_toml = Toml.Parser.from_string "key=[1,2]";;
val parsed_toml : Toml.Value.table = <abstr>

utop # Toml.to_int_array (Toml.key "key") parsed_toml;;
- : int list = [1; 2]
```

### Writing Toml data

```ocaml
# let toml_data = Toml.Table.empty |> Toml.Table.add
  (Toml.key "key") (Toml.of_int_array [1;2]);;
val toml_data : Toml.Value.value Toml.Table.t = <abstr>

# let buffer = Buffer.create 100;;
val buffer : Buffer.t = <abstr>

# let formatter = Format.formatter_of_buffer buffer;;
val formatter : Format.formatter = <abstr>

# Toml.Printer.table formatter toml_data;;
- : unit = ()

# Buffer.contents buffer;;
- : bytes = "key = [1, 2]\n"
```

## Limitations

* Keys don't quite follow the Toml standard. Both section keys (eg, `[key1.key2]`) and ordinary keys (`key=...`) may not contain the following characters: space, '\t', '\n', '\r', '.', '[', ']', '"' and '#'.
