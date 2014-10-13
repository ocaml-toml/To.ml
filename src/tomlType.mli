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

and table = (string * value) list
