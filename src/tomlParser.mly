%{
open TomlInternal.Type

let to_path str : string list = Str.split (Str.regexp "\\.") str

type t = Value of value
       | Table of (string, t) Hashtbl.t
       | Tables of ((string, t) Hashtbl.t) list

type group_names = string list

type group_header = SimpleGroup of group_names | NestedGroup of group_names

let ensure_group_table_exists root_table group_names =
  List.fold_left
      (fun tbl w -> try match Hashtbl.find tbl w with
         | Table tbl          -> tbl
         | Value _            -> failwith (w ^ " is a value")
         | Tables (tbl1::rest as tbls) ->
             let last_table = List.rev tbls |> List.hd
             in last_table
         | Tables [] ->
             let sub = Hashtbl.create 0 in
             Hashtbl.replace tbl w (Tables [sub]);
             sub
      with Not_found ->
        let sub = Hashtbl.create 0 in
        Hashtbl.add tbl w (Table sub); sub)
      root_table group_names

let add_value group_table key value =
  if Hashtbl.mem group_table key then failwith (key ^ " is already defined")
  else Hashtbl.add group_table key (Value value)

let add_simple_group root_table group_names key_values =
  let group_table = ensure_group_table_exists root_table group_names in
  List.iter (fun (key, value) -> add_value group_table key value) key_values

let add_nested_group root_table group_names key_values =
  let create_table_from_values tables key_values =
    let new_table = Hashtbl.create 0 in
    List.iter(fun (key, value) ->
      add_value new_table key value) key_values;
    Tables (tables @ [new_table])
  in
  (* With [[x.y.z]], x and y should be tables and z an array of tables *)
  let reversed_group_names = List.rev group_names in
  let group_names_to_create = List.tl reversed_group_names |> List.rev in
  (* Create x and y as tables *)
  let group_table = ensure_group_table_exists root_table group_names_to_create in
  let last_group_name = List.hd reversed_group_names in
  (* Create z as an array of tables *)
  try match Hashtbl.find group_table last_group_name with
  | Tables tables ->
      Hashtbl.replace group_table last_group_name (create_table_from_values tables key_values);
  | Table _       -> failwith (last_group_name ^ " is a table, not an array of tables")
  | Value _       -> failwith (last_group_name ^ " is a value")
  with Not_found ->
    Hashtbl.add group_table last_group_name (create_table_from_values [] key_values)

let rec convert = function
  | Table t ->
    TTable (hashtbl_to_map t)
  | Value v -> v
  | Tables tables ->
    let tables_as_list_of_toml_values =
      tables
      |> List.filter (fun table -> Hashtbl.length table > 0)
      |> List.map hashtbl_to_map
    in
    TArray (NodeTable tables_as_list_of_toml_values)
and hashtbl_to_map hashtbl =
  Hashtbl.fold (fun k v map ->
    Map.add (Key.of_string k) (convert v) map) hashtbl Map.empty

%}

/* OcamlYacc definitions */
%token <bool> BOOL
%token <int> INTEGER
%token <float> FLOAT
%token <string> STRING
%token <Unix.tm> DATE
%token <string> KEY
%token LBRACK RBRACK EQUAL EOF COMMA

%start toml

%type <TomlInternal.Type.table> toml
%type <string * TomlInternal.Type.value> keyValue
%type <TomlInternal.Type.array> array_start

%%
/* Grammar rules */
toml:
 | keyValue* pair(group_header, keyValue*)* EOF
   { let groups = (SimpleGroup [], $1) :: $2
     and table = Hashtbl.create 0 in
     List.iter (fun (group_header, key_values) ->
       match group_header with
       | SimpleGroup group_names ->
         add_simple_group table group_names key_values
       | NestedGroup group_names ->
         add_nested_group table group_names key_values
     ) groups;
     match convert (Table table) with
     | TTable t -> t
     | _ -> assert false }

group_header:
 | LBRACK LBRACK KEY RBRACK RBRACK { NestedGroup (to_path $3) }
 | LBRACK KEY RBRACK { SimpleGroup (to_path $2) }

keyValue:
    KEY EQUAL value { ($1, $3) }

value:
    BOOL { TBool($1) }
  | INTEGER { TInt($1) }
  | FLOAT { TFloat($1) }
  | STRING { TString($1) }
  | DATE { TDate $1 }
  | LBRACK array_start { TArray($2) }

array_start:
    RBRACK { NodeEmpty }
  | BOOL array_end(BOOL) { NodeBool($1 :: $2) }
  | INTEGER array_end(INTEGER) { NodeInt($1 :: $2) }
  | FLOAT array_end(FLOAT) { NodeFloat($1 :: $2) }
  | STRING array_end(STRING) { NodeString($1 :: $2) }
  | DATE array_end(DATE) { NodeDate($1 :: $2) }
  | LBRACK array_start nested_array_end { NodeArray($2 :: $3) }

array_end(param):
    COMMA param array_end(param) { $2 :: $3 }
  | COMMA? RBRACK { [] }

nested_array_end:
    COMMA LBRACK array_start nested_array_end { $3 :: $4 }
  | COMMA? RBRACK { [] }

%%
