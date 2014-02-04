
let parse string = Parsetoml.toml Tomlex.tomlex (Lexing.from_string string)
(** Parse a TOML file
  @return (string, TomlValue) Hashtbl.t
*)
