(** The TOML parser interface *)

(** {2 Parsing functions } *)

val parse : Lexing.lexbuf -> TomlType.tomlTable
val from_string : string -> TomlType.tomlTable
val from_channel : in_channel -> TomlType.tomlTable
val from_filename : string -> TomlType.tomlTable

(** {2 Filter entries }
    Use this if you want to filter entries of a table.
    You can retreive all values, direct values, or subtables. 
    All functions return a (key, value) list *)

(** No filter *)
val toml_to_list :
  ('a, TomlType.tomlValue) Hashtbl.t -> ('a * TomlType.tomlValue) list

(** Filter tables tables (skip direct values) *)
val tables_to_list :
  ('a, TomlType.tomlValue) Hashtbl.t -> ('a * TomlType.tomlTable) list

(** Filter direct values (skip tables) *)
val values_to_list :
  ('a, TomlType.tomlValue) Hashtbl.t -> ('a * TomlType.tomlValue) list

(** {2 Extract a specific value }
    These functions take the toml table as first argument and the key of 
    value as second one. They have three behaviors:{ul list}
    - The key is found and the type is good. The primitive value is returned
    - The key is not found: raise Not_found
    - The key is found but the type doesn't match: raise Bad_type *)

(** Bad_type expections carry (key, expected type) data *)
exception Bad_type of (string * string)

(** {3 Primitive getters }
    Use these functions to get a single value of a known OCaml type *)

val get_bool : (string, TomlType.tomlValue) Hashtbl.t -> string -> bool
val get_int : (string, TomlType.tomlValue) Hashtbl.t -> string -> int
val get_float : (string, TomlType.tomlValue) Hashtbl.t -> string -> float
val get_string : (string, TomlType.tomlValue) Hashtbl.t -> string -> string
val get_date : (string, TomlType.tomlValue) Hashtbl.t -> string -> Unix.tm

(** {3 Table getter }
    Get a subtable *)

val get_table :
  (string, TomlType.tomlValue) Hashtbl.t -> string -> TomlType.tomlTable

(** {3 Array getters}
    Arrays contents are returned as lists *)

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
