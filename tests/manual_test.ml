(** Reads the toml file you give in argument and parse it
  * Then print it
  *)
open Toml
open TomlPprint

let _ =
  print_string @@ print @@ Toml.from_channel stdin
