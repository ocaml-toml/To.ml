type t =
  [ `Int of int
  | `Float of float
  | `String of string
  | `Bool of bool
  | `List of t list
  | `Assoc of (string * t) list
  ]

open Toml.Types

let rec of_toml_table v : t =
  let f (k, v) = (Toml.Types.Table.Key.to_string k, of_toml_value v) in
  let pairs = List.map f (Toml.Types.Table.bindings v) in
  `Assoc pairs

and of_toml_value = function
  | TBool b -> `Bool b
  | TInt i -> `Int i
  | TFloat f -> `Float f
  | TString s -> `String s
  | TDate f -> `Float f
  | TArray a -> `List (of_toml_array a)
  | TTable t -> of_toml_table t

and of_toml_array = function
  | NodeEmpty -> []
  | NodeBool bs -> List.map (fun v -> `Bool v) bs
  | NodeInt is -> List.map (fun v -> `Int v) is
  | NodeFloat fs -> List.map (fun v -> `Float v) fs
  | NodeString ss -> List.map (fun v -> `String v) ss
  | NodeDate fs -> List.map (fun v -> `Float v) fs
  | NodeArray arrs -> List.map (fun v -> `List (of_toml_array v)) arrs
  | NodeTable ts -> List.map (fun v -> of_toml_table v) ts

let source =
  let module D = CConv.Decode in
  let rec src =
    { D.emit =
        (fun dec (x : t) ->
          match x with
          | `Bool b -> dec.D.accept_bool src b
          | `Int i -> dec.D.accept_int src i
          | `Float f -> dec.D.accept_float src f
          | `String s -> dec.D.accept_string src s
          | `List l -> dec.D.accept_list src l
          | `Assoc l -> dec.D.accept_record src l )
    }
  in
  src

let decode dec x = CConv.decode source dec (of_toml_table x)

let decode_exn dec x = CConv.decode_exn source dec (of_toml_table x)
