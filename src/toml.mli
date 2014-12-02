(** The TOML module interface *)

(** {2 Data types} *)
(**
 Data types returned by the parser, can be used to build a Toml structure
 from scratch.

 You should use the {!Toml.Value.To} and {!Toml.Value.Of} modules to navigate between
 plain OCaml data structures and Toml data structures.
*)

module Table : sig

  (**
   The type of a Toml table. Toml tables implement the {!Map} interface.
   Their keys are of type {!Toml.Table.Key.t}.
   *)

  module Key : sig
    include module type of TomlInternal.Type.Key
  end

  include Map.S
      with type key = Key.t

end

(**
 Turns a string into a table key.
 @throws Toml.Table.Key.Bad_key if the key contains invalid characters.
*)
val key : string -> Table.Key.t

module Value : sig

  (**
   A Toml value. Covers Toml integers, floats, booleans, strings, dates. Also
   has constructors for tables and arrays.
   *)
  type value

  (**
   A Toml array. May contain any Toml data type except for tables.
   *)
  type array

  (**
   A Toml table of {!Toml.Value.value}.
   *)
  type table = value Table.t

  module To : sig

    (** Bad_type exceptions carry [expected type] data *)
    exception Bad_type of string

    (**
     From Toml type to OCaml primitive. All conversion functions in this
     module (and its [Array] submodule) may throw [Bad_type] if the Toml type is
     incorrect (eg, using {!Toml.Value.To.string} on a Toml boolean).
    *)

    val bool : value -> bool
    val int : value -> int
    val float : value -> float
    val string : value -> string
    val date : value -> Unix.tm
    val array : value -> array
    val table : value -> table

    module Array : sig

      (** Array functions. As a TOML array may nest types,
          handling them needs a dedicated module. *)
      val bool : array -> bool list
      val int : array -> int list
      val float : array -> float list
      val string : array -> string list
      val date : array -> Unix.tm list
      val array : array -> array list
    end

  end

  module Of : sig

    (**
     From OCaml primitive to Toml type.

     OCaml strings should be valid UTF-8, and OCaml dates should be in UTC.
    *)

    val bool : bool -> value
    val int : int -> value
    val float : float -> value
    val string : string -> value
    val date : Unix.tm -> value
    val array : array -> value
    val table : table -> value

    module Array : sig
      val bool : bool list -> array
      val int : int list -> array
      val float : float list -> array
      val string : string list -> array
      val date : Unix.tm list -> array
      val array : array list -> array
    end

  end

end

(** {2 Parser} *)
(** Simple parsing functions. *)

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
   *)
  val parse : Lexing.lexbuf -> string -> Value.table

  (**
   Given an UTF-8 string, returns a Toml table.

   @raise Toml.Parser.Error if the string is not valid Toml.
  *)
  val from_string : string -> Value.table

  (**
   Given an input channel, returns a Toml table.

   @raise Toml.Parser.Error if the data in the channel is not valid Toml.
  *)
  val from_channel : in_channel -> Value.table

  (**
   Given a filename, returns a Toml table.

   @raise Toml.Parser.Error if the data in the file is not valid Toml.
   @raise Pervasives.Sys_error if the file could not be opened.
  *)
  val from_filename : string -> Value.table

end


(** {2 Printing} *)

module Printer : sig

  (**
   Given a Toml value and a formatter, inserts a valid Toml representation of
   this value in the formatter.
  *)
  val value : Format.formatter -> Value.value -> unit

  (**
   Given a Toml table and a formatter, inserts a valid Toml representation of
   this value in the formatter.
  *)
  val table : Format.formatter -> Value.table -> unit

  (**
   Given a Toml array and a formatter, inserts a valid Toml representation of
   this value in the formatter.
  *)
  val array : Format.formatter -> Value.array -> unit

end

(** {2 Comparison} *)

module Compare : sig

  (** Given two Toml values, return [-1], [0] or [1] depending on whether the
   first is smaller, equal or greater than the second *)
  val value : Value.value -> Value.value -> int

  (** Given two Toml arrays, return [-1], [0] or [1] depending on whether the
   first is smaller, equal or greater than the second *)
  val array : Value.array -> Value.array -> int

  (** Given two Toml tables, return [-1], [0] or [1] depending on whether the
   first is smaller, equal or greater than the second *)
  val table : Value.table -> Value.table -> int

end
