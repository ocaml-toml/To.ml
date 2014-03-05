(** Toml types used by parser *)

(** Toml arrays are mplemented as lists. Typed, but can contain multiple 
    types if you nest tables *)
type tomlNodeArray =
  | NodeEmpty
  | NodeBool of bool list
  | NodeInt of int list
  | NodeFloat of float list
  | NodeString of string list
  | NodeDate of Unix.tm list
  | NodeArray of tomlNodeArray list (* this can have any type *)

(** Toml primitive values *)
and tomlValue =
  | TBool of bool
  | TInt of int
  | TFloat of float
  | TString of string
  | TDate of Unix.tm
  | TArray of tomlNodeArray
  | TTable of tomlTable

(** Toml table. Implemented as hash table. *)
and tomlTable = (string, tomlValue) Hashtbl.t
