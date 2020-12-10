# toml [![Actions Status](https://github.com/ocamlpro/toml/workflows/build/badge.svg)](https://github.com/ocamlpro/toml/actions)

[OCaml] parser for [TOML].

## Documentation

Have a look at the [online documentation]. Otherwise, here's a quickstart guide.

### Reading TOML data

```ocaml
utop # (* This will return either `Ok $tomltable or `Error $error_with_location *)
let ok_or_error = Toml.Parser.from_string "key=[1,2]";;
val ok_or_error : Toml.Parser.result = `Ok <abstr> 

utop # (* You can use the 'unsafe' combinator to get the result directly, or an
exception if a parsing error occurred *)
let parsed_toml = Toml.Parser.(from_string "key=[1,2]" |> unsafe);;
val parsed_toml : Toml.Types.table = <abstr>

utop # (* Use simple pattern matching to read the value *)
Toml.Types.Table.find (Toml.Min.key "key") parsed_toml;;
- : Toml.Types.value = Toml.Types.TArray (Toml.Types.NodeInt [1; 2])
```

### Writing TOML data

```ocaml
utop # let toml_data = Toml.of_key_values [
    Toml.key "ints", Toml.Types.TArray (Toml.Types.NodeInt [1; 2]);
    Toml.key "string", Toml.Types.TString "string value";
];;
val toml_data : Toml.Types.table = <abstr>

utop # Toml.Printer.string_of_table toml_data;;
- : bytes = "ints = [1, 2]\nstring = \"string value\"\n"
```

### Lenses

Through lenses, it is possible to read/write deeply nested data with ease.
The Toml.Lenses module provides partial lenses (that is, lenses returning
`option` types) to manipulate TOML data structures.

```ocaml
utop # let toml_data = Toml.Parser.(from_string "
[this.is.a.deeply.nested.table]
answer=42" |> unsafe);;
val toml_data : Toml.Types.table = <abstr>

utop # Toml.Lenses.(get toml_data (
  key "this" |-- table
  |-- key "is" |-- table
  |-- key "a" |-- table
  |-- key "deeply" |-- table
  |-- key "nested" |-- table
  |-- key "table" |-- table
  |-- key "answer"|-- int ));;
- : int option = Some 42

utop # let maybe_toml_data' = Toml.Lenses.(set 2015 toml_data (
  key "this" |-- table
  |-- key "is" |-- table
  |-- key "a" |-- table
  |-- key "deeply" |-- table
  |-- key "nested" |-- table
  |-- key "table" |-- table
  |-- key "answer"|-- int ));;
val maybe_toml_data' : Toml.Types.table option = Some <abstr>

utop # Toml.Printer.string_of_table toml_data';;
- : bytes = "[this.is.a.deeply.nested.table]\nanswer = 2015\n"

```

### `toml_cconv`

A second library, `toml_cconv` for encoding/decoding with [cconv] can be installed if `cconv` is present.

`toml` supports ppx via [cconv]:

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
val toml : Toml.Types.table = <abstr>

utop # Toml_cconv.decode_exn decode toml;;
- : t = {ints = [1; 2]; string = "string value"}
```

## Limitations

* Keys don't quite follow the TOML standard. Both section keys (eg,
`[key1.key2]`) and ordinary keys (`key=...`) may not contain the
following characters: space, `\t`, `\n`, `\r`, `.`, `[`, `]`, `"` and `#`.

[cconv]: https://github.com/c-cube/cconv
[OCaml]: https://ocaml.org/
[online documentation]: http://ocaml-toml.github.io/To.ml/
[TOML]: https://toml.io
