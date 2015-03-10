(** This module is for internal usage only,
    and is not exposed in final library. *)

module Type = struct

  (** {2 Toml tables} *)

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

    (** Compare x y returns 0 if x is equal to y, a negative integer if x is
        less than y, and a positive integer if x is greater than y. *)
    let compare = Pervasives.compare

    (** Bare keys only allow [A-Za-z0-9_-].
        @raise Type.Key.Bad_key if other char is found. *)
    let bare_key_of_string s =
      String.iter (fun c -> let c = Char.code c in
                            if ( c < 48 (* 0 *)
                                 && c <> 45 (* - *) )
                               || ( c > 57 (* 0 *)
                                    && c < 65 (* A *) )
                               || ( c > 90 (* Z *)
                                    && c < 97 (* a *)
                                    && c <> 95 (* _ *) )
                               || ( c > 122)
                            then raise (Bad_key s)) s ;
      KeyBare s

    (** FIXME: Ensure that: *)
    (** Quoted keys follow the exact same rules as basic strings. *)
    let quoted_key_of_string s = KeyQuoted s

    let to_string = function
      | KeyBare k -> k
      | KeyQuoted k -> "\"" ^ k ^ "\""

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
