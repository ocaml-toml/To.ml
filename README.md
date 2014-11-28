# Toml (OCaml parser for TOML)
[![Build Status](https://travis-ci.org/sagotch/To.ml.png?branch=master)](https://travis-ci.org/sagotch/To.ml)
[![Coverage Status](https://coveralls.io/repos/sagotch/To.ml/badge.png)](https://coveralls.io/r/sagotch/To.ml)

Ocaml parser for TOML [(Tom's Obvious Minimal Language)](https://github.com/mojombo/toml) v0.2.0.

## Dependencies

Toml need Ocaml 4.0 at least. Check your local installation with `ocamlc -v`.

This project use **ocamllex** and **menhir** parsing features. In order to
compile tests you will also need **OUnit** and **bisect** is required to
generate code coverage summary.

## Install

* Via Opam: `opam install toml`
* From source:
```
git clone https://github.com/sagotch/To.ml
cd To.ml
make build
make install
```
make install may need sudo.

## Usage

`open Toml` in your file(s), and link toml library when compiling. For
instance, using ocamlbuild:
```
ocamlbuild -use-ocamlfind -package toml foo.byte
```

### Reading Toml data

```ocaml
utop # let parsed_toml = Toml.Parser.from_string "key=[1,2]";;
val parsed_toml : TomlInternal.Type.table = <abstr>

utop # Toml.Table.find (Toml.Table.Key.of_string "key") parsed_toml;;
- : TomlInternal.Type.value = TomlInternal.Type.TArray (TomlInternal.Type.NodeInt [1; 2])
```

### Writing Toml data

```ocaml
utop # let toml_data = Toml.Table.empty |> Toml.Table.add
(Toml.Table.Key.of_string "key") (Toml.Value.Of.array (Toml.Value.Of.Array.int
[1;2]));;
val toml_data : TomlInternal.Type.value Toml.Table.t = <abstr>

utop # let buffer = Buffer.create 100;;
val buffer : Buffer.t = <abstr>

utop # let formatter = Format.formatter_of_buffer buffer;;
val formatter : Format.formatter = <abstr>

utop # Toml.Printer.table formatter toml_data;;
- : unit = ()

utop # Buffer.contents buffer;;
- : bytes = "key = [1, 2]\n"
```

## Limitations

* Array of tables is not supported.
