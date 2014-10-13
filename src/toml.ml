open TomlType

module Map = Map.Make(String)
type table = TomlType.table
type array = TomlType.array
type value = TomlType.value

module Parser = struct
  let parse lexbuf = TomlParser.toml TomlLexer.tomlex lexbuf
  let from_string s = parse (Lexing.from_string s)
  let from_channel c = parse (Lexing.from_channel c)
  let from_filename f = from_channel (open_in f)
end

module Table = struct

  let empty = Map.empty

  let find = Map.find

  let add = Map.add

end

module Value = struct

  module To = struct

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
