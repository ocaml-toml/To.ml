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

  (** Exception raised when a parsing error occurs. Contains a (message, location) tuple. *)
  exception Error of (string * location)

  (**
   Given a lexer buffer and a source (eg, a filename), returns a Toml table.

   @raise Toml.Parser.Error if the buffer is not valid Toml.
   @since 2.0.0
   *)
  val parse : Lexing.lexbuf -> string -> TomlTypes.table

  (**
   Given an UTF-8 string, returns a Toml table.

   @raise Toml.Parser.Error if the string is not valid Toml.
   @since 2.0.0
  *)
  val from_string : string -> TomlTypes.table

  (**
   Given an input channel, returns a Toml table.

   @raise Toml.Parser.Error if the data in the channel is not valid Toml.
   @since 2.0.0
  *)
  val from_channel : in_channel -> TomlTypes.table

  (**
   Given a filename, returns a Toml table.

   @raise Toml.Parser.Error if the data in the file is not valid Toml.
   @raise Pervasives.Sys_error if the file could not be opened.
   @since 2.0.0
  *)
  val from_filename : string -> TomlTypes.table

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

  val string_of_value : TomlTypes.value -> string

  val string_of_table : TomlTypes.table -> string

  val string_of_array : TomlTypes.array -> string

end

val key : string -> TomlTypes.Table.Key.t

val of_key_values : (TomlTypes.Table.Key.t * TomlTypes.value) list -> TomlTypes.table
