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
   Their keys are of type {!TomlInternal.Type.Key.t}, and their values are of type
   {!TomlInternal.Type.value}.
   *)

  module Key : sig
    include module type of TomlInternal.Type.Key
  end

  include Map.S
      with type key = Key.t

end

module Value : sig

  type value
  type array
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
   Given a lexer buffer, returns a Toml table.

   @raise TomlParser.Error if the buffer is not valid Toml.
   *)
  val parse : Lexing.lexbuf -> Value.table

  (**
   Given an UTF-8 string, returns a Toml table.

   @raise TomlParser.Error if the string is not valid Toml.
  *)
  val from_string : string -> Value.table

  (**
   Given an input channel, returns a Toml table.

   @raise TomlParser.Error if the data in the channel is not valid Toml.
  *)
  val from_channel : in_channel -> Value.table

  (**
   Given a filename, returns a Toml table.

   @raise TomlParser.Error if the data in the file is not valid Toml.
   @raise Pervasives.Sys_error if the file could not be opened.
  *)
  val from_filename : string -> Value.table

end


(** {2 Printing} *)

module Printer : sig

  (**
   Given an Toml value and a formatter, inserts a valid Toml representation of
   this value in the formatter.
  *)
  val value : Format.formatter -> Value.value -> unit

  (**
   Given an Toml table and a formatter, inserts a valid Toml representation of
   this value in the formatter.
  *)
  val table : Format.formatter -> Value.table -> unit

  (**
   Given an Toml array and a formatter, inserts a valid Toml representation of
   this value in the formatter.
  *)
  val array : Format.formatter -> Value.array -> unit

end

module Equal : sig

  val value : Value.value -> Value.value -> bool

  val array : Value.array -> Value.array -> bool

  val table : Value.table -> Value.table -> bool

end
