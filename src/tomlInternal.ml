(** This module is for internal usage only,
    and is not exposed in final library. *)

module Type = struct

  module Key = struct
    type t = string
    let compare = Pervasives.compare
    let of_string s = s
  end

  module Map = Map.Make(Key)

  type array =
    | NodeEmpty
    | NodeBool of bool list
    | NodeInt of int list
    | NodeFloat of float list
    | NodeString of string list
    | NodeDate of Unix.tm list
    | NodeArray of array list (* this can have any type *)

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

module Dump = struct

  open Type

  let list (stringifier : 'a -> string) (els : 'a list)  =
    String.concat "; " @@ List.map stringifier els

  let rec table (tbl : table) : string =
    Map.fold (fun k v acc -> (k, v) :: acc) tbl []
    |> list (fun (k, v) -> k ^ "->" ^ value v)

  and array : array -> string = function
    | NodeEmpty -> ""
    | NodeBool l -> list string_of_bool l
    | NodeInt l ->  list string_of_int l
    | NodeFloat l ->  list string_of_float l
    | NodeString l ->  list (fun x -> x) l
    | NodeDate l ->  list date l
    | NodeArray l ->  list array l

  and value : value -> string = function
    | TBool b -> "TBool(" ^ string_of_bool b ^ ")"
    | TInt i ->  "TInt(" ^ string_of_int i ^ ")"
    | TFloat f -> "TFloat(" ^ string_of_float f ^ ")"
    | TString s -> "TString(" ^ s ^ ")"
    | TDate d -> "TDate(" ^ date d ^ ")"
    | TArray arr -> "[" ^ array arr ^ "]"
    | TTable tbl -> "TTable(" ^ table tbl ^ ")"

  and date (d : Unix.tm) : string =
    "{"
    ^ string_of_int d.Unix.tm_year
    ^ "-"
    ^ string_of_int d.Unix.tm_mon
    ^ "-"
    ^ string_of_int d.Unix.tm_mday
    ^ "-"
    ^ "}"
end

module Equal = struct

  let rec value (x : Type.value) (y : Type.value) = match x, y with
    | TArray x, TArray y -> array x y
    | TTable x, TTable y -> table x y
    | _, _               -> x = y

  and array (x : Type.array) (y : Type.array) = match x, y with
    | NodeArray x, NodeArray y -> List.for_all2 array x y
    | _, _                     -> x = y

  and table (x : Type.table) (y : Type.table) =
    Type.Map.equal value x y

end
