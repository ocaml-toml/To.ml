open TomlType

let string_of_list (stringifier : 'a -> string) (els : 'a list)  =
  String.concat "; " @@ List.map stringifier els

let rec string_of_table tbl : string =
  Hashtbl.fold (fun k v acc -> (k, v) :: acc) tbl []
  |> string_of_list (fun (k, v) -> k ^ "->" ^ string_of_entrie v)

and string_of_entrie : tomlEntrie -> string = function
  | TTable tbl -> "TTable(" ^ string_of_table tbl ^ ")"
  | TValue v -> "TValue(" ^ string_of_val v ^ ")"

and string_of_node : tomlNodeArray -> string = function
  | NodeBool l -> string_of_list string_of_bool l
  | NodeInt l ->  string_of_list string_of_int l
  | NodeFloat l ->  string_of_list string_of_float l
  | NodeString l ->  string_of_list (fun x -> x) l
  | NodeDate l ->  string_of_list (fun x -> x) l
  | NodeArray l ->  string_of_list string_of_node l

and string_of_val : tomlValue -> string = function
  | TBool b -> "TBool(" ^ string_of_bool b ^ ")"
  | TInt i ->  "TInt(" ^ string_of_int i ^ ")"
  | TFloat f -> "TFloat(" ^ string_of_float f ^ ")"
  | TString s -> "TString(" ^ s ^ ")"
  | TDate d -> "TDate(" ^ d ^ ")"
  | TArray arr -> "[" ^ string_of_node arr ^ "]"
