(**
  * Types of To.ml goes here to avoid circular dependency
  * All type manipulation goes here
  *)

(** Toml arrays
  * - They are implemented as lists the spirit of TOML simplicity
  * - They are typed, but can change the type if you nest them
  *)
type tomlNodeArray =
  | NodeBool of bool list
  | NodeInt of int list
  | NodeFloat of float list
  | NodeString of string list
  | NodeDate of string list
  | NodeArray of tomlNodeArray list (* this can have any type *)

(** Toml values *)
type tomlValue =
  | TBool of bool
  | TInt of int
  | TFloat of float
  | TString of string
  | TDate of string (* TODO ? *)
  | TArray of tomlNodeArray

(** A Toml configuration
  * That's basically an Hashtable of pairs (Key * Value)
  *
  * Values are prefixed by their groups, so in
  * <code TOML>
  * [group1]
  * key1 = value1
  * [group2.subgroup1]
  * key2 = value2
  * </code>
  *
  * Reference key1 with "group1.key1" and key2 with "group2.subgroup1.key2"
  * All keys are in the same hashtable, that's why we need prefixes
  *)
type toml = (string, tomlValue) Hashtbl.t

let init () = Hashtbl.create 13
let add toml (str, node) = Hashtbl.add toml str node

