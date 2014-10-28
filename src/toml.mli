(** The TOML parser interface *)

open TomlInternal.Type

module Parser : sig

  (** {2 Parsing functions } *)
  val parse : Lexing.lexbuf -> table
  val from_string : string -> table
  val from_channel : in_channel -> table
  val from_filename : string -> table

end

module Table : sig

  module Key = TomlInternal.Type.Key

  (** Create a empty TOML table *)
  val empty : table

  val find : Key.t -> table -> value

  val add : Key.t -> value -> table -> table

end

module Value : sig

  module To : sig

    (** Bad_type expections carry [expected type] data *)
    exception Bad_type of string

    (** From Toml type to OCaml primitive. *)

    val bool : value -> bool
    val int : value -> int
    val float : value -> float
    val string : value -> string
    val date : value -> Unix.tm
    val array : value -> array
    val table : value -> table

    module Array : sig

      (** Array functions. As TOML array mey nest types,
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

    (** From OCaml primitive to Toml type. *)

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

module Printer : sig

  val value : Format.formatter -> TomlInternal.Type.value -> unit

  val table : Format.formatter -> TomlInternal.Type.table -> unit

  val array : Format.formatter -> TomlInternal.Type.array -> unit

end
