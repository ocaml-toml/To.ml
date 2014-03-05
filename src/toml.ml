open TomlType

(** Parsing functions a TOML file
  @return (string, TomlValue) Hashtbl.t
*)

let parse lexbuf = TomlParser.toml TomlLexer.tomlex lexbuf
let from_string s = parse (Lexing.from_string s)
let from_channel c = parse (Lexing.from_channel c)
let from_filename f = from_channel (open_in f)

(**
 * Functions to get the list of direct values / sub tables of a tomlTable
 *)

let toml_to_list toml = Hashtbl.fold (fun k v acc -> (k, v)::acc) toml []

let tables_to_list toml =
  Hashtbl.fold (fun k v acc ->
                match v with
                | TTable v -> (k, v) :: acc
                | _ -> acc) toml []

let values_to_list toml =
  Hashtbl.fold (fun k v acc ->
                match v with
                | TTable _ -> acc
                | _ -> (k, v) :: acc) toml []


let get = Hashtbl.find
exception Bad_type of (string * string)

(**
 * Functions to retreive values of an expected type
 *)

let get_table toml key = match (get toml key) with
  | TTable(tbl) -> tbl
  | _ -> raise (Bad_type (key, "value"))

let get_bool toml key = match get toml key with
  | TBool b -> b
  | _ -> raise (Bad_type (key, "boolean"))

let get_int toml key = match get toml key with
  | TInt i -> i
  | _ -> raise (Bad_type (key, "integer"))

let get_float toml key = match get toml key with
  | TFloat f -> f
  | _ -> raise (Bad_type (key, "float"))

let get_string toml key = match get toml key with
  | TString s -> s
  | _ -> raise (Bad_type (key, "string"))

let get_date toml key = match get toml key with
  | TDate d -> d
  | _ -> raise (Bad_type (key, "date"))

(**
 * Functions to retreive OCaml primitive type list
 *)

let get_bool_list toml key = match get toml key with
  | TArray (NodeBool b) -> b
  | TArray (NodeEmpty) -> []
  | _ -> raise (Bad_type (key, "boolean array"))

let get_int_list toml key = match get toml key with
  | TArray (NodeInt i) -> i
  | TArray (NodeEmpty) -> []
  | _ -> raise (Bad_type (key, "integer array"))

let get_float_list toml key = match get toml key with
  | TArray (NodeFloat f) -> f
  | TArray (NodeEmpty) -> []
  | _ -> raise (Bad_type (key, "float array"))

let get_string_list toml key = match get toml key with
  | TArray (NodeString s) -> s
  | TArray (NodeEmpty) -> []
  | _ -> raise (Bad_type (key, "string array"))

let get_date_list toml key = match get toml key with
  | TArray (NodeDate d) -> d
  | TArray (NodeEmpty) -> []
  | _ -> raise (Bad_type (key, "date array"))
