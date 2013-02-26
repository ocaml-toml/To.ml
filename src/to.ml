(**
  * Main file of To.ml
  * All To.ml manipulation goes here
  *)

type TomlValue =
  | TomlBool of bool
  | TomlInt of int
  | TomlFloat of float
  | TomlString of string
  | TomlDate of string
  | TomlArray of int list

type TomlNode =
  | Group of TomlNode
  | KeyValue of TomlValue

type toml = (string, TomlNode) Hashtbl.t

