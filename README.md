# Toml (OCaml parser for TOML)

[![Gitter](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/mackwic/To.ml?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)
[![Build Status](https://travis-ci.org/mackwic/To.ml.png?branch=master)](https://travis-ci.org/mackwic/To.ml)
[![Coverage Status](https://coveralls.io/repos/mackwic/To.ml/badge.png?branch=master)](https://coveralls.io/r/mackwic/To.ml?branch=master)

OCaml parser for TOML [(Tom's Obvious Minimal Language)](https://github.com/mojombo/toml) v0.4.0.

## Table of contents

- [A foreword to beginners](#a-foreword-to-beginners)
- [Dependencies](#dependencies)
- [Install](#install)
- [Documentation](#documentation)
- [Usage](#usage)
- [Reading Toml data](#reading-toml-data)
- [Writing Toml data](#writing-toml-data)
- [Limitations](#limitations)

## A foreword to beginners

New to OCaml ? Don't worry, just check theses links to begin with:

- [Play with OCaml online and discover the language](http://try.ocamlpro.com/)
- [See OCaml code examples](http://rosettacode.org/wiki/Category:OCaml)
- [The full official list of Ocaml tutorials](http://ocaml.org/learn/tutorials/)
- Recommended tools:
    - [OCaml Package Manager](https://opam.ocaml.org) (also install compilers)
    - [OCaml IDE](http://www.algo-prog.info/ocaide/install.php)
    - [OCaml Interpretor](https://github.com/diml/utop)

## Dependencies

Toml need OCaml 4.0 at least. Check your local installation with `ocamlc -v`.

This project use **ocamllex** and **menhir** parsing features. In order to
compile tests you will also need **OUnit** and **bisect** is required to
generate code coverage summary.

## Install

* Via OPAM: `opam install toml`
* From source:
```bash
git clone https://github.com/sagotch/To.ml
cd To.ml
make build
make install
```
make install may need sudo.

## Documentation

You can build documentation from sources with `make doc`, or browse
[github pages](http://mackwic.github.io/To.ml/) of the project.

## Usage

`open Toml` in your file(s), and link the toml library when compiling. For
instance, using ocamlbuild:
```bash
ocamlbuild -use-ocamlfind -package toml foo.byte
```
or using an OCaml toplevel (like utop):
```bash
$ utop
utop # #use "topfind";;
utop # #require "toml";; (* now you can use the Toml module *)
```

### Reading Toml data

```ocaml
utop # (* This will return either `Ok $tomltable or `Error $error_with_location
*)
let ok_or_error = Toml.Parser.from_string "key=[1,2]";;
val ok_or_error : Toml.Parser.result = `Ok <abstr> 

utop # (* You can use the 'unsafe' combinator to get the result directly, or an
exception if a parsing error occurred *)
let parsed_toml = Toml.Parser.(from_string "key=[1,2]" |> unsafe);;
val parsed_toml : TomlTypes.table = <abstr>

utop # (* Use simple pattern matching to read the value *)
TomlTypes.Table.find (Toml.key "key") parsed_toml;;
- : TomlTypes.value = TomlTypes.TArray (TomlTypes.NodeInt [1; 2])
```

### Writing Toml data

```ocaml
utop # let toml_data = Toml.of_key_values [
    Toml.key "ints", TomlTypes.TArray (TomlTypes.NodeInt [1; 2]);
    Toml.key "string", TomlTypes.TString "string value";
];;
val toml_data : TomlTypes.table = <abstr>

utop # Toml.Printer.string_of_table toml_data;;
- : bytes = "ints = [1, 2]\nstring = \"string value\"\n"
```

### Lenses

Through lenses, it is possible to read/write deeply nested data with ease.
The TomlLenses module provides partial lenses (that is, lenses returning
`option` types) to manipulate Toml data structures.

```ocaml
utop # let toml_data = Toml.Parser.(from_string "
[this.is.a.deeply.nested.table]
answer=42" |> unsafe);;
val toml_data : TomlTypes.table = <abstr>

utop # TomlLenses.(get toml_data (
  key "this" |-- table
  |-- key "is" |-- table
  |-- key "a" |-- table
  |-- key "deeply" |-- table
  |-- key "nested" |-- table
  |-- key "table" |-- table
  |-- key "answer"|-- int ));;
- : int option = Some 42

utop # let maybe_toml_data' = TomlLenses.(set 2015 toml_data (
  key "this" |-- table
  |-- key "is" |-- table
  |-- key "a" |-- table
  |-- key "deeply" |-- table
  |-- key "nested" |-- table
  |-- key "table" |-- table
  |-- key "answer"|-- int ));;
val maybe_toml_data' : TomlTypes.table option = Some <abstr>

utop # Toml.Printer.string_of_table toml_data';;
- : bytes = "[this.is.a.deeply.nested.table]\nanswer = 2015\n"

```

### PPX support

To.ml supports ppx via [cconv](https://github.com/c-cube/cconv)

``` ocaml
utop # #require "cconv.ppx";;
utop # #require "toml.cconv";;

utop # type t = { ints : int list; string : string } [@@deriving cconv];;
type t = { ints : int list; string : string; }                                                  
val encode : t CConv.Encode.encoder = {CConv.Encode.emit = <fun>}                               
val decode : t CConv.Decode.decoder =
  {CConv.Decode.dec =
    {CConv.Decode.accept_unit = <fun>; accept_bool = <fun>;
     accept_float = <fun>; accept_int = <fun>; accept_int32 = <fun>;
     accept_int64 = <fun>; accept_nativeint = <fun>; accept_char = <fun>;
     accept_string = <fun>; accept_list = <fun>; accept_option = <fun>;
     accept_record = <fun>; accept_tuple = <fun>; accept_sum = <fun>}}

utop # let toml = Toml.Parser.(from_string "ints = [1, 2]\nstring = \"string value\"\n"
                               |> unsafe);;
val toml : TomlTypes.table = <abstr>

utop # TomlCconv.decode_exn decode toml;;
- : t = {ints = [1; 2]; string = "string value"}
```

## Limitations

* Keys don't quite follow the Toml standard. Both section keys (eg,
`[key1.key2]`) and ordinary keys (`key=...`) may not contain the
following characters: space, '\t', '\n', '\r', '.', '[', ']', '"' and '#'.

## Contributing

- Fork this repository
- `oasis setup && ./configure --enable-tests --enable-report && make test`
- Submit a PR *or* open an issue so that we can create a branch and a
  PR associated to it.
  This is better because then, all the Toml maintainers can push commits
  to this branch.
