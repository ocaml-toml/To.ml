(*
 * The TOML parser interface
 * *)

(***
 * These are the helpers used to parse a TOML input
 * 
 * @note:
 *   type TomlType.tomlTable = (string, TomlValue) Hashtbl.t
 * *)
val parse : Lexing.lexbuf -> TomlType.tomlTable
val from_string : string -> TomlType.tomlTable
val from_channel : in_channel -> TomlType.tomlTable
val from_filename : string -> TomlType.tomlTable

(**
 * Use this if you want to extract the list of the sub values
 **)

(* @param tomlTable
 * @return the list of all (key, value) contained in tomlTable *)
val toml_to_list :
  ('a, TomlType.tomlValue) Hashtbl.t -> ('a * TomlType.tomlValue) list
(* @param tomlTable
 * @return the list of all the tables (key, table) contained in tomlTable *)
val tables_to_list :
  ('a, TomlType.tomlValue) Hashtbl.t -> ('a * TomlType.tomlTable) list
(* @param tomlTable
 * @return the list of all the non-tables (key, value) contained in tomlTable *)
val values_to_list :
  ('a, TomlType.tomlValue) Hashtbl.t -> ('a * TomlType.tomlValue) list

(**
 * Use this if you want to extract a specific value
 *
 * All the following functions have three behaviors:
 *  1. The key is found and the type is good. The primitive value is returned
 *  2. The key is not found: raise Not_found
 *  3. The key is found but the type doesn't match: raise Bad_type (key,
 *  expected type)
 * *)

exception Bad_type of (string * string)

(* Primitive getters *)
val get_bool : (string, TomlType.tomlValue) Hashtbl.t -> string -> bool
val get_int : (string, TomlType.tomlValue) Hashtbl.t -> string -> int
val get_float : (string, TomlType.tomlValue) Hashtbl.t -> string -> float
val get_string : (string, TomlType.tomlValue) Hashtbl.t -> string -> string
val get_date : (string, TomlType.tomlValue) Hashtbl.t -> string -> Unix.tm

(* Table getter *)
val get_table :
  (string, TomlType.tomlValue) Hashtbl.t -> string -> TomlType.tomlTable

(* Array getters *)
val get_bool_list :
  (string, TomlType.tomlValue) Hashtbl.t -> string -> bool list
val get_int_list :
  (string, TomlType.tomlValue) Hashtbl.t -> string -> int list
val get_float_list :
  (string, TomlType.tomlValue) Hashtbl.t -> string -> float list
val get_string_list :
  (string, TomlType.tomlValue) Hashtbl.t -> string -> string list
val get_date_list :
  (string, TomlType.tomlValue) Hashtbl.t -> string -> Unix.tm list
