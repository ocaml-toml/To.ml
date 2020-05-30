(** {2 Toml tables} *)

module Table = struct

  module Key : sig
    type t
    exception Bad_key of string
    val compare : t -> t -> int
    val bare_key_of_string : string -> t
    val quoted_key_of_string : string -> t
    val to_string : t -> string
  end = struct

    (** A strongly-typed key. *)
    type t = KeyBare of string
           | KeyQuoted of string

    (** Exception thrown when an invalid character is found in a key.*)
    exception Bad_key of string

    (** Bare keys only allow [A-Za-z0-9_-].
        @raise Type.Key.Bad_key if other char is found. *)
    let validate_bare_key s =
      String.iter (function
        | 'a' .. 'z'
        | 'A' .. 'Z'
        | '0' .. '9'
        | '_'
        | '-' -> ()
        | _ -> raise (Bad_key s))
      s

    let bare_key_of_string s =
      validate_bare_key s;
      KeyBare s

    (* FIXME: Ensure that: *)
    (** Quoted keys follow the exact same rules as basic strings. *)
    let quoted_key_of_string s = KeyQuoted s

    let to_string = function
      | KeyBare k -> k
      | KeyQuoted k -> "\"" ^ k ^ "\""

    (** Compare x y returns 0 if x is equal to y, a negative integer if x is
        less than y, and a positive integer if x is greater than y. *)
    let compare m1 m2 =
      String.compare (to_string m1) (to_string m2)

  end
  
  include Map.Make(Key)

  let of_key_values key_values = List.fold_left ( fun tbl (key, value) ->
      add key value tbl) empty key_values

end

type array =
  | NodeEmpty
  | NodeBool of bool list
  | NodeInt of int list
  | NodeFloat of float list
  | NodeString of string list
  | NodeDate of float list
  | NodeArray of array list (* this can have any type *)
  | NodeTable of table list

and value =
  | TBool of bool
  | TInt of int
  | TFloat of float
  | TString of string
  | TDate of float
  | TArray of array
  | TTable of table

and table = value Table.t
