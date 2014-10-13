open TomlType

let string_of_list (stringifier : 'a -> string) (els : 'a list)  =
  String.concat "; " @@ List.map stringifier els

let rec string_of_table tbl : string =
  Map.fold (fun k v acc -> (k, v) :: acc) tbl []
  |> string_of_list (fun (k, v) -> k ^ "->" ^ string_of_val v)

and string_of_node : array -> string = function
  | NodeEmpty -> ""
  | NodeBool l -> string_of_list string_of_bool l
  | NodeInt l ->  string_of_list string_of_int l
  | NodeFloat l ->  string_of_list string_of_float l
  | NodeString l ->  string_of_list (fun x -> x) l
  | NodeDate l ->  string_of_list string_of_date l
  | NodeArray l ->  string_of_list string_of_node l

and string_of_val : value -> string = function
  | TBool b -> "TBool(" ^ string_of_bool b ^ ")"
  | TInt i ->  "TInt(" ^ string_of_int i ^ ")"
  | TFloat f -> "TFloat(" ^ string_of_float f ^ ")"
  | TString s -> "TString(" ^ s ^ ")"
  | TDate d -> "TDate(" ^ string_of_date d ^ ")"
  | TArray arr -> "[" ^ string_of_node arr ^ "]"
  | TTable tbl -> "TTable(" ^ string_of_table tbl ^ ")"

and string_of_date (d : Unix.tm) : string =
  "{"
  ^ string_of_int d.Unix.tm_year
  ^ "-"
  ^ string_of_int d.Unix.tm_mon
  ^ "-"
  ^ string_of_int d.Unix.tm_mday
  ^ "-"
  ^ "}"
