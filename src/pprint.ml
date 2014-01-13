open TypeTo

let list_printer stringifier list =
  List.fold_right (fun elt s -> (stringifier elt)^", "^s) list ""

let rec string_of_node = function
  | NodeBool l -> list_printer string_of_bool l
  | NodeInt l ->  list_printer string_of_int l
  | NodeFloat l ->  list_printer string_of_float l
  | NodeString l ->  list_printer (fun x -> x) l
  | NodeDate l ->  list_printer (fun x -> x) l
  | NodeArray l ->  list_printer string_of_node l

let string_of_toml = function
  | TBool b -> "TBool("^(string_of_bool b)^")"
  | TInt i ->  "TInt("^(string_of_int i)^")"
  | TFloat f -> "TFloat("^(string_of_float f)^")"
  | TString s -> "TString("^s^")"
  | TDate d -> "TDate("^d^")"
  | TArray arr -> "["^(string_of_node arr)^"]"

let print_val k v =
  Printf.printf "%s::%s" k (string_of_toml v)

let print h =
  Hashtbl.iter print_val h
