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
 @raise Toml.Table.Key.Bad_key if the key contains invalid characters.
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
      val table : array -> table list
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
      val table : table list -> array
    end

  end

end

(**
 {2 Convenience functions}

 Toml offers a number of convenience function, to access and find values with a
 minimum of typing.
*)

(**
 {3 From Toml values to OCaml values}

 Given a Toml value (of type {!Toml.Value.value}), returns an OCaml value.

 Example:

 {v
  # let table = Toml.Table.empty
    |> Toml.Table.add (Toml.key "foo") (Toml.Value.Of.string "bar");;
  val table : Toml.Value.value Toml.Table.t = <abstr>

  # let bar = Toml.Table.find (Toml.key "foo") table
    |> Toml.Value.To.string;;
  val bar : bytes = "bar" 

  # let table = Toml.Table.empty
    |> Toml.Table.add (Toml.key "fortytwos")
         (Toml.Value.Of.Array.int [42;42] |> Toml.Value.Of.array);;
  val table : Toml.Value.value Toml.Table.t = <abstr>

  # let fortytwos = Toml.Table.find (Toml.key "fortytwos") table
    |> Toml.to_int_array;;
  val fortytwos : int list = [42; 42]
 v}

 All conversion functions raise {!Toml.Value.To.Bad_type} if the type is wrong.
*)

val to_bool : Value.value -> bool

val to_int : Value.value -> int

val to_float : Value.value -> float

val to_string : Value.value -> string

val to_date : Value.value -> Unix.tm

val to_table : Value.value -> Value.value Table.t

val to_bool_array : Value.value -> bool list

val to_int_array : Value.value -> int list

val to_float_array : Value.value -> float list

val to_string_array : Value.value -> string list

val to_date_array : Value.value -> Unix.tm list

val to_array_array : Value.value -> Value.array list

(**
 {3 Getting OCaml values from a table}

 These functions take a Toml key, a Toml table, and return a plain OCaml value
 if the key was found in the table.

 Example:

 {v
  # let table = Toml.Table.empty
    |> Toml.Table.add (Toml.key "foo") (Toml.of_string "bar");;
  val table : Toml.Value.value Toml.Table.t = <abstr>

  # let bar = Toml.get_string (Toml.key "foo") table;;
  val bar : bytes = "bar" 

  # let table = Toml.Table.empty
    |> Toml.Table.add (Toml.key "fortytwos")
         (Toml.of_int_array [42;42]);;
  val table : Toml.Value.value Toml.Table.t = <abstr>

  # let fortytwos = Toml.get_int_array (Toml.key "fortytwos") table;;
  val fortytwos : int list = [42; 42]
 v}


 All retrieval functions raise {!Not_found} if the value was not found in the
 table, and {!Toml.Value.To.Bad_type} if the type is wrong.

*)

val get_bool : Table.Key.t -> Value.value Table.t -> bool

val get_int : Table.Key.t -> Value.value Table.t -> int

val get_float : Table.Key.t -> Value.value Table.t -> float

val get_string : Table.Key.t -> Value.value Table.t -> string

val get_date : Table.Key.t -> Value.value Table.t -> Unix.tm

val get_table : Table.Key.t -> Value.value Table.t -> Value.value Table.t

val get_bool_array : Table.Key.t -> Value.value Table.t -> bool list

val get_int_array : Table.Key.t -> Value.value Table.t -> int list

val get_float_array : Table.Key.t -> Value.value Table.t -> float list

val get_string_array : Table.Key.t -> Value.value Table.t -> string list

val get_date_array : Table.Key.t -> Value.value Table.t -> Unix.tm list

val get_array_array : Table.Key.t -> Value.value Table.t -> Value.array list

(**
 {3 From OCaml values to Toml values}

 These shorthand functions take an OCaml value and turn them into the
 appropriate Toml value.

 Example:

 {v
  # let table = Toml.Table.empty
    |> Toml.Table.add (Toml.key "fortytwos")
         (Toml.of_int_array [42;42]);;
  val table : Toml.Value.value Toml.Table.t = <abstr>
 v}

*)

val of_bool : bool -> Value.value

val of_int : int -> Value.value

val of_float : float -> Value.value

val of_string : string -> Value.value

val of_date : Unix.tm -> Value.value

val of_table : Value.table -> Value.value

val of_bool_array : bool list -> Value.value

val of_int_array : int list -> Value.value

val of_float_array : float list -> Value.value

val of_string_array : string list -> Value.value

val of_date_array : Unix.tm list -> Value.value

val of_array_array : Value.array list -> Value.value

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
