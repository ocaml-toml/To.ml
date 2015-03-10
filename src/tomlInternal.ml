(** This module is for internal usage only,
    and is not exposed in final library. *)

module Type = struct

  (** {2 Toml tables} *)

  module Key : sig
    type t
    exception Bad_key of string
    val compare : t -> t -> int

    val of_string : string -> t

    val to_string : t -> string

  end = struct
    (**
     A strongly-typed key. Used for both section keys ([[key1.key2]]) and
     plain keys ([key=...]).

     Keys don't quite follow the Toml standard. They may not contain the
     following characters: space, [\t], [\n], [\r], [.], [\[], [\]], double
     quote and [#].
    *)
    type t = string

    (** Exception thrown when an invalid character is found in a key.*)
    exception Bad_key of string

    (**
     Compare x y returns 0 if x is equal to y, a negative integer if x is
     less than y, and a positive integer if x is greater than y.
    *)
    let compare = Pervasives.compare

    (**
     Builds a key from a plain string.

     @raise TomlInternal.Type.Key.Bad_key if the key contains invalid
     characters.
    *)
    let of_string s =
        String.iter (fun ch ->
            if String.contains " \t\n\r.[]\"#" ch then
                raise (Bad_key s)) s;
        s

    (**
     Returns the key as a plain string.
    *)
    let to_string key = key

  end

  module Map = Map.Make(Key)

  (** {2 Toml values} *)

  type array =
    | NodeEmpty
    | NodeBool of bool list
    | NodeInt of int list
    | NodeFloat of float list
    | NodeString of string list
    | NodeDate of Unix.tm list
    | NodeArray of array list (* this can have any type *)
    | NodeTable of table list

  and value =
    | TBool of bool
    | TInt of int
    | TFloat of float
    | TString of string
    | TDate of Unix.tm
    | TArray of array
    | TTable of table

  and table = value Map.t

end

module Compare = struct

  open Type

  let rec value (x : Type.value) (y : Type.value) = match x, y with
    | TArray x, TArray y -> array x y
    | TTable x, TTable y -> table x y
    | _, _               -> compare x y

  and array (x : Type.array) (y : Type.array) = compare x y

  and table (x : Type.table) (y : Type.table) =
    Type.Map.compare value x y

end
