module Parser = struct
 
  open Lexing 

  type location = {
    source: string;
    line: int;
    column: int;
    position: int;
  }

  exception Error of (string * location)

  let parse lexbuf source =
    try
      TomlParser.toml TomlLexer.tomlex lexbuf
    with TomlParser.Error ->
      let location = {
        source = source;
        line = lexbuf.lex_curr_p.pos_lnum;
        column = (lexbuf.lex_curr_p.pos_cnum - lexbuf.lex_curr_p.pos_bol);
        position = lexbuf.lex_curr_p.pos_cnum;
      } in
      let msg =
        Printf.sprintf "Error in %s at line %d at column %d (position %d)"
          source location.line location.column location.position
      in
      raise (Error (msg, location))
  let from_string s = parse (Lexing.from_string s) "<string>"
  let from_channel c = parse (Lexing.from_channel c) "<channel>"
  let from_filename f = parse (open_in f |> Lexing.from_channel) f
end

module Table = struct

  include TomlInternal.Type.Map

  module Key = struct
    include TomlInternal.Type.Key
  end

end

let key = Table.Key.of_string

module Value = struct

  type value = TomlInternal.Type.value
  type array = TomlInternal.Type.array
  type table = value Table.t

  module To = struct

    open TomlInternal.Type

    exception Bad_type of string

    let exn t = raise (Bad_type t)

    let bool   = function TBool b   -> b | _ -> exn "bool"
    let int    = function TInt i    -> i | _ -> exn "int"
    let float  = function TFloat f  -> f | _ -> exn "float"
    let string = function TString s -> s | _ -> exn "string"
    let date   = function TDate d   -> d | _ -> exn "date"
    let table  = function TTable t  -> t | _ -> exn "table"
    let array  = function TArray a  -> a | _ -> exn "array"

    module Array = struct

      let maybe_empty fn = function NodeEmpty -> [] | a -> fn a

      let bool = maybe_empty
          (function NodeBool b   -> b | _ -> exn "bool array")
      let int = maybe_empty
          (function NodeInt i    -> i | _ -> exn "int array")
      let float = maybe_empty
          (function NodeFloat f  -> f | _ -> exn "float array")
      let string = maybe_empty
          (function NodeString s -> s | _ -> exn "string array")
      let date = maybe_empty
          (function NodeDate d   -> d | _ -> exn "date array")
      let array = maybe_empty
          (function NodeArray a  -> a | _ -> exn "array array")
    end

  end

  module Of = struct

    open TomlInternal.Type

    let bool b   = TBool b
    let int i    = TInt i
    let float f  = TFloat f
    let string s = TString s
    let date d   = TDate d
    let table t  = TTable t
    let array a  = TArray a

    module Array = struct
      let maybe_empty fn = function [] -> NodeEmpty | a -> fn a

      let bool b   = maybe_empty (fun b -> NodeBool b) b
      let int i    = maybe_empty (fun i -> NodeInt i) i
      let float f  = maybe_empty (fun f -> NodeFloat f) f
      let string s = maybe_empty (fun s -> NodeString s) s
      let date d   = maybe_empty (fun d -> NodeDate d) d
      let array a  = maybe_empty (fun a -> NodeArray a) a
    end
  end

end

let to_bool = Value.To.bool
let to_int = Value.To.int
let to_float = Value.To.float
let to_string = Value.To.string
let to_date = Value.To.date
let to_table = Value.To.table

let to_bool_array value = Value.To.array value |> Value.To.Array.bool
let to_int_array value = Value.To.array value |> Value.To.Array.int
let to_float_array value = Value.To.array value |> Value.To.Array.float
let to_string_array value = Value.To.array value |> Value.To.Array.string
let to_date_array value = Value.To.array value |> Value.To.Array.date
let to_array_array value = Value.To.array value |> Value.To.Array.array

let get_bool key table = Table.find key table |> to_bool
let get_int key table = Table.find key table |> to_int
let get_float key table = Table.find key table |> to_float
let get_string key table = Table.find key table |> to_string
let get_date key table = Table.find key table |> to_date
let get_table key table = Table.find key table |> to_table

let get_bool_array key table = Table.find key table |> to_bool_array
let get_int_array key table = Table.find key table |> to_int_array
let get_float_array key table = Table.find key table |> to_float_array
let get_string_array key table = Table.find key table |> to_string_array
let get_date_array key table = Table.find key table |> to_date_array
let get_array_array key table = Table.find key table |> to_array_array

let of_bool = Value.Of.bool
let of_int = Value.Of.int
let of_float = Value.Of.float
let of_string = Value.Of.string
let of_date = Value.Of.date
let of_table = Value.Of.table

let of_bool_array value = Value.Of.Array.bool value |> Value.Of.array
let of_int_array value = Value.Of.Array.int value |> Value.Of.array
let of_float_array value = Value.Of.Array.float value |> Value.Of.array
let of_string_array value = Value.Of.Array.string value |> Value.Of.array
let of_date_array value = Value.Of.Array.date value |> Value.Of.array
let of_array_array value = Value.Of.Array.array value |> Value.Of.array

module Compare = TomlInternal.Compare

module Printer = struct

  let value formatter toml_value = TomlPrinter.value formatter toml_value

  let table formatter toml_table = TomlPrinter.table formatter toml_table

  let array formatter toml_array = TomlPrinter.array formatter toml_array

end
