open TomlTypes

module Parser = struct

  open Lexing

  type location = {
    source: string;
    line: int;
    column: int;
    position: int;
  }

  type result = [`Ok of TomlTypes.table | `Error of (string * location)]

  let parse lexbuf source =
    try
      let result = TomlParser.toml TomlLexer.tomlex lexbuf in
      `Ok result
    with (TomlParser.Error | Failure _) as error ->
      let formatted_error_msg = match error with
      | Failure failure_msg -> Printf.sprintf ": %s" failure_msg
      | _                   -> ""
      in
      let location = {
        source = source;
        line = lexbuf.lex_curr_p.pos_lnum;
        column = (lexbuf.lex_curr_p.pos_cnum - lexbuf.lex_curr_p.pos_bol);
        position = lexbuf.lex_curr_p.pos_cnum;
      } in
      let msg =
        Printf.sprintf "Error in %s at line %d at column %d (position %d)%s"
          source location.line location.column location.position formatted_error_msg
      in
      `Error (msg, location)
  let from_string s = parse (Lexing.from_string s) "<string>"
  let from_channel c = parse (Lexing.from_channel c) "<channel>"
  let from_filename f =
    let c = open_in f in
    try
      let res = parse (Lexing.from_channel c) f in
      close_in c;
      res
    with e ->
      close_in_noerr c;
      raise e

  exception Error of (string * location)

  (** A combinator to force the result. Raise [Error] if the result was [`Ok] *)
  let unsafe result =
    match result with
    | `Ok toml_table          -> toml_table
    | `Error (msg, location)  -> raise (Error (msg, location))
end

module Compare = struct

  let rec list_compare ~f l1 l2 = match l1, l2 with
    | head1::tail1, head2::tail2  ->
      let comp_result = f head1 head2 in
      if comp_result != 0 then
        comp_result
      else
        list_compare ~f tail1 tail2
    | [], head2::tail2            -> -1
    | head1::tail1, []            -> 1
    | [], []                      -> 0

  let rec value (x : TomlTypes.value) (y : TomlTypes.value) = match x, y with
    | TArray x, TArray y -> array x y
    | TTable x, TTable y -> table x y
    | _, _               -> compare x y

  and array (x : TomlTypes.array) (y : TomlTypes.array) = match x, y with
    | NodeTable nt1, NodeTable nt2 -> list_compare ~f:table nt1 nt2
    | _ -> compare x y
  and table (x : TomlTypes.table) (y : TomlTypes.table) =
    TomlTypes.Table.compare value x y

end

module Printer = struct

  let value formatter toml_value = TomlPrinter.value formatter toml_value

  let table formatter toml_table = TomlPrinter.table formatter toml_table

  let array formatter toml_array = TomlPrinter.array formatter toml_array

  let string_of_value = TomlPrinter.string_of_value

  let string_of_table = TomlPrinter.string_of_table

  let string_of_array = TomlPrinter.string_of_array

end

let key = TomlTypes.Table.Key.bare_key_of_string

let of_key_values = TomlTypes.Table.of_key_values
