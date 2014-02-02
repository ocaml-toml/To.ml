%{
(** Header *)
open TypeTo

let to_path str : string list = Str.split (Str.regexp "\\.") str

let add table path (key, value) =
  let table =
    List.fold_left
      (fun tbl -> fun w -> try match Hashtbl.find tbl w with
                               | TTable tbl -> tbl
                               | _ -> failwith (w ^ " is a value")
                           with Not_found ->
                             let sub = Hashtbl.create 0 in
                             Hashtbl.add tbl w (TTable sub); sub)
      table path in
  try ignore(Hashtbl.find table key); failwith (key ^ " is already defined")
  with Not_found -> Hashtbl.add table key (TValue value)

%}

/* OcamlYacc definitions */
%token <bool> BOOL
%token <int> INTEGER
%token <float> FLOAT
%token <string> STRING DATE
%token <string> KEY
%token LBRACK RBRACK EQUAL EOF COMMA

%start toml

%type <TypeTo.tomlTable> toml
%type <string list> group
%type <(string * tomlValue)> keyValue
%type <tomlNodeArray> array_start

%%
/* Grammar rules */
toml:
 | keyValue* pair(group, keyValue*)* EOF
   { let l = ([], $1) :: $2
     and table = Hashtbl.create 0 in
     List.iter (fun (g, v) -> List.iter (fun v -> add table g v) v) l;
     table }

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
    RBRACK { NodeBool([]) }
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

