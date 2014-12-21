%{
open TomlInternal.Type

let to_path str : string list = Str.split (Str.regexp "\\.") str

type t = Value of value
       | Table of (string, t) Hashtbl.t

let ensure_group_table_exists root_table group_names =
  List.fold_left
      (fun tbl w -> try match Hashtbl.find tbl w with
         | Table tbl -> tbl
         | Value _   -> failwith (w ^ " is a value")
      with Not_found ->
        let sub = Hashtbl.create 0 in
        Hashtbl.add tbl w (Table sub); sub)
      root_table group_names

let add_value group_table key value =
  if Hashtbl.mem group_table key then failwith (key ^ " is already defined")
  else Hashtbl.add group_table key (Value value)

let add_group root_table group_names key_values =
  let group_table = ensure_group_table_exists root_table group_names in
  List.iter (fun (key, value) -> add_value group_table key value) key_values

let rec convert = function
  | Table t ->
    TTable (Hashtbl.fold
              (fun k v map -> Map.add
                  (Key.of_string k)
                  (convert v) map) t Map.empty)
  | Value v -> v

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
%type <string list> group
%type <string * TomlInternal.Type.value> keyValue
%type <TomlInternal.Type.array> array_start

%%
/* Grammar rules */
toml:
 | keyValue* pair(group, keyValue*)* EOF
   { let groups = ([], $1) :: $2
     and table = Hashtbl.create 0 in
     List.iter (fun (group_names, key_values) ->
       add_group table group_names key_values) groups;
     match convert (Table table) with
     | TTable t -> t
     | _ -> assert false }

group:
  LBRACK KEY RBRACK { to_path $2 }

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
