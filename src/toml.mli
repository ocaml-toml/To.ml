module Parser : sig

  (** Parses raw data into Toml data structures *)

  (**
   The location of an error. The [source] gives the source file of the error.
   The other fields give the location of the error inside the source. They all
   start from one. The [line] is the line number, the [column] is the number of
   characters from the start of the line, and the [position] is the number of
   characters from the start of the source.
  *)
  type location = {
    source: string;
    line: int;
    column: int;
    position: int;
  }

  (** Parsing result. Either Ok or error (which contains a (message, location)
      tuple). *)
  type result = [`Ok of TomlTypes.table | `Error of (string * location)]

  (**
   Given a lexer buffer and a source (eg, a filename), returns a [result].

   @raise Toml.Parser.Error if the buffer is not valid Toml.
   @since 2.0.0
   *)
  val parse : Lexing.lexbuf -> string -> result

  (**
   Given an UTF-8 string, returns a [result].

   @since 2.0.0
  *)
  val from_string : string -> result

  (**
   Given an input channel, returns a [result].

   @since 2.0.0
  *)
  val from_channel : in_channel -> result

  (**
   Given a filename, returns a [result].

   @raise Pervasives.Sys_error if the file could not be opened.
   @since 2.0.0
  *)
  val from_filename : string -> result

  exception Error of (string * location)

  (**
   A combinator to force the result. Raise [Error] if the result was [`Error].
   @since 4.0.0
  *)
  val unsafe : result -> TomlTypes.table

end

module Compare : sig

  (** Given two Toml values, return [-1], [0] or [1] depending on whether the
   first is smaller, equal or greater than the second

   @since 2.0.0
  *)
  val value : TomlTypes.value -> TomlTypes.value -> int

  (** Given two Toml arrays, return [-1], [0] or [1] depending on whether the
   first is smaller, equal or greater than the second

   @since 2.0.0
  *)
  val array : TomlTypes.array -> TomlTypes.array -> int

  (** Given two Toml tables, return [-1], [0] or [1] depending on whether the
   first is smaller, equal or greater than the second

   @since 2.0.0
  *)
  val table : TomlTypes.table -> TomlTypes.table -> int

end

module Printer : sig

  (**
   Given a Toml value and a formatter, inserts a valid Toml representation of
   this value in the formatter.

   @since 2.0.0
  *)
  val value : Format.formatter -> TomlTypes.value -> unit

  (**
   Given a Toml table and a formatter, inserts a valid Toml representation of
   this value in the formatter.

   @since 2.0.0
  *)
  val table : Format.formatter -> TomlTypes.table -> unit

  (**
   Given a Toml array and a formatter, inserts a valid Toml representation of
   this value in the formatter.

   @raise Invalid_argument if the array is an array of tables
   @since 2.0.0
  *)
  val array : Format.formatter -> TomlTypes.array -> unit

  (**
   Turns a Toml value into a string.
   @since 4.0.0
  *)
  val string_of_value : TomlTypes.value -> string

  (**
   Turns a Toml table into a string.
   @since 4.0.0
  *)
  val string_of_table : TomlTypes.table -> string

  (**
   Turns a Toml array into a string.
   @since 4.0.0
  *)
  val string_of_array : TomlTypes.array -> string

end

(**
 Turns a string into a table key.
 @raise TomlTypes.Table.Key.Bad_key if the key contains invalid characters.
 @since 2.0.0
 *)
val key : string -> TomlTypes.Table.Key.t

(**
 Builds a Toml table out of a list of (key, value) tuples.
 @since 4.0.0
 *)
val of_key_values : (TomlTypes.Table.Key.t * TomlTypes.value) list -> TomlTypes.table
