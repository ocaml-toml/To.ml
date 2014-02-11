open TomlType

(** Parsing functions a TOML file
  @return (string, TomlValue) Hashtbl.t
*)

let parse lexbuf = TomlParser.toml |> TomlLexer.tomlex
let from_string = parse |> Lexing.from_string
let from_channel = parse |> Lexing.from_channel
let from_filename = from_channel |> open_in

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
exception Bad_Type of (string * string)

(**
 * Functions to retreive values of an expected type
 *)

let get_table toml key = function get toml key
  | TTable(tbl) -> tbl
  | _ -> raise (Bad_Type (key * "value"))

let get_bool toml key = function get toml key
  | TBool b -> b
  | _ -> raise (Bad_Type (key * "boolean"))

let get_int toml key = function get toml key
  | TInt i -> i
  | _ -> raise (Bad_Type (key * "integer"))

let get_float toml key = function get toml key
  | TFloat f -> f
  | _ -> raise (Bad_Type (key * "float"))

let get_string toml key = function get toml key
  | TString s -> s
  | _ -> raise (Bad_Type (key * "string"))

let get_date toml key = function get toml key
  | TDate d -> d
  | _ -> raise (Bad_Type (key * "date"))

(**
 * Functions to retreive OCaml primitive type list
 *)

let get_bool_list toml key = function get toml key
  | TArray (NodeBool b) -> b
  | _ -> raise (Bad_Type (key * "boolean array"))

let get_int_list toml key = function get toml key
  | TArray (NodeInt i) -> i
  | _ -> raise (Bad_Type (key * "integer array"))

let get_float_list toml key = function get toml key
  | TArray (NodeFloat f) -> f
  | _ -> raise (Bad_Type (key * "float array"))

let get_string_list toml key = function get toml key
  | TArray (NodeString s) -> s
  | _ -> raise (Bad_Type (key * "string array"))

let get_date_list toml key = function get toml key
  | TArray (NodeDate d) -> d
  | _ -> raise (Bad_Type (key * "date array"))
