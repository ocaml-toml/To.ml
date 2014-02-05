
let parse string = TomlParser.toml TomlLexer.tomlex (Lexing.from_string string)
(** Parse a TOML file
  @return (string, TomlValue) Hashtbl.t
*)
